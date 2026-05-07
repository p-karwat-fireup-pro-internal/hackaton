import Foundation
import Network

@MainActor
@Observable
final class AppStore {
    enum SyncState: Equatable {
        case synced
        case queued(Int)
        case offline
    }

    enum Phase {
        case bootstrapping
        case loggedOut
        case lockedOut
        case ready
    }

    enum Transition {
        case start, complete

        var pathSuffix: String {
            switch self {
            case .start:    return "/start"
            case .complete: return "/complete"
            }
        }

        var nextStatus: JobStatus {
            switch self {
            case .start:    return .in_progress
            case .complete: return .done
            }
        }
    }

    // Public state
    var phase: Phase = .bootstrapping
    var user: UserDTO?
    var jobs: [JobDTO] = []
    var photosByJob: [String: [PhotoDTO]] = [:]
    var pendingNewJobBanner = false
    var syncState: SyncState = .synced

    // Internal
    private let api: APIClient
    private let keychain: KeychainStore
    private var pendingActions: [PendingAction] = []
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "AppStore.monitor")
    private var lastPathStatus: NWPath.Status?
    // Mirror of the keychain access token so per-request reads don't hop the
    // main actor and hit Security framework — login/refresh keep this in sync.
    private var cachedAccessToken: String?

    init(api: APIClient = APIClient(), keychain: KeychainStore = KeychainStore()) {
        self.api = api
        self.keychain = keychain
        self.cachedAccessToken = keychain.load(.accessToken)
        Task { await api.setTokenSource(self) }
        startMonitor()
    }

    // MARK: - Bootstrap

    func bootstrap() async {
        if keychain.load(.refreshToken) != nil {
            await loadProfileAndJobs()
        } else {
            phase = .loggedOut
        }
    }

    // MARK: - Auth

    func login(email: String, password: String) async throws {
        let body = ["email": email, "password": password]
        let res: LoginResponse = try await api.send(.post, "/auth/login", body: body, as: LoginResponse.self)
        try keychain.save(res.accessToken, for: .accessToken)
        try keychain.save(res.refreshToken, for: .refreshToken)
        try keychain.save(res.user.id, for: .userId)
        cachedAccessToken = res.accessToken
        user = res.user
        await loadJobs()
        applyOfflineSimulationFlag()
        phase = .ready
    }

    func logout() async {
        if let refresh = keychain.load(.refreshToken) {
            try? await api.sendVoid(.post, "/auth/logout", body: ["refreshToken": refresh])
        }
        keychain.clearAll()
        cachedAccessToken = nil
        user = nil
        jobs = []
        photosByJob = [:]
        pendingNewJobBanner = false
        syncState = .synced
        phase = .loggedOut
    }

    // MARK: - Jobs

    func loadProfileAndJobs() async {
        do {
            async let me: UserDTO = api.send(.get, "/me", as: UserDTO.self)
            async let fresh: [JobDTO] = api.send(.get, "/jobs", as: [JobDTO].self)
            let (u, j) = try await (me, fresh)
            user = u
            setJobs(j)
            applyOfflineSimulationFlag()
            phase = .ready
        } catch APIError.unauthorized {
            keychain.clearAll()
            cachedAccessToken = nil
            phase = .loggedOut
        } catch {
            phase = .loggedOut
        }
    }

    func loadJobs() async {
        do {
            let res: [JobDTO] = try await api.send(.get, "/jobs", as: [JobDTO].self)
            setJobs(res)
        } catch {
            // keep cached list, surface offline state
            setSyncState(.offline)
        }
    }

    func startJob(_ id: String) async {
        await mutateJob(id, transition: .start)
    }

    func completeJob(_ id: String) async {
        await mutateJob(id, transition: .complete)
    }

    private func mutateJob(_ id: String, transition: Transition) async {
        let path = "/jobs/\(id)\(transition.pathSuffix)"
        if isOfflineSim {
            enqueue(.transition(jobId: id, path: path))
            applyOptimisticTransition(id: id, to: transition.nextStatus)
            setSyncState(.queued(pendingActions.count))
            return
        }
        do {
            let updated: JobDTO = try await api.send(.post, path, as: JobDTO.self)
            apply(updated)
        } catch {
            enqueue(.transition(jobId: id, path: path))
            applyOptimisticTransition(id: id, to: transition.nextStatus)
            setSyncState(.queued(pendingActions.count))
        }
    }

    func uploadPhoto(jobId: String, image: Data, description: String, mimeType: String) async {
        do {
            let photo: PhotoDTO = try await api.sendMultipart(
                "/jobs/\(jobId)/photos",
                fields: ["description": description],
                fileField: "file",
                fileData: image, filename: "photo.jpg", mimeType: mimeType,
                as: PhotoDTO.self)
            appendPhoto(photo, jobId: jobId)
        } catch {
            enqueue(.uploadPhoto(jobId: jobId, data: image, description: description, mimeType: mimeType))
            setSyncState(.queued(pendingActions.count))
        }
    }

    func acceptNewJob() {
        pendingNewJobBanner = false
    }

    func dismissNewJobBanner() {
        pendingNewJobBanner = false
    }

    // MARK: - Helpers

    private func apply(_ job: JobDTO) {
        if let idx = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[idx] = job
        }
    }

    private func applyOptimisticTransition(id: String, to next: JobStatus) {
        guard let idx = jobs.firstIndex(where: { $0.id == id }) else { return }
        jobs[idx].status = next
    }

    private func appendPhoto(_ photo: PhotoDTO, jobId: String) {
        var list = photosByJob[jobId] ?? []
        list.append(photo)
        photosByJob[jobId] = list
    }

    private func setJobs(_ fresh: [JobDTO]) {
        if jobs != fresh { jobs = fresh }
        let banner = fresh.contains { $0.isNew }
        if pendingNewJobBanner != banner { pendingNewJobBanner = banner }
    }

    private func setSyncState(_ next: SyncState) {
        if syncState != next { syncState = next }
    }

    // MARK: - Offline queue

    enum PendingAction {
        case transition(jobId: String, path: String)
        case uploadPhoto(jobId: String, data: Data, description: String, mimeType: String)
    }

    private func enqueue(_ a: PendingAction) {
        pendingActions.append(a)
    }

    private func startMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self else { return }
                self.handlePathUpdate(path.status)
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func handlePathUpdate(_ status: NWPath.Status) {
        defer { lastPathStatus = status }
        // Only react on transitions — NWPathMonitor fires repeated `.satisfied`
        // updates during interface flapping and we don't want to retry the
        // pending queue on every one of them.
        guard status != lastPathStatus else { return }
        if status == .satisfied {
            Task { await flushPending() }
        } else {
            setSyncState(.offline)
        }
    }

    private func flushPending() async {
        guard !pendingActions.isEmpty, !isOfflineSim else { return }
        var remaining: [PendingAction] = []
        for action in pendingActions {
            do {
                switch action {
                case .transition(_, let path):
                    let updated: JobDTO = try await api.send(.post, path, as: JobDTO.self)
                    apply(updated)
                case .uploadPhoto(let jobId, let data, let desc, let mime):
                    let photo: PhotoDTO = try await api.sendMultipart(
                        "/jobs/\(jobId)/photos",
                        fields: ["description": desc],
                        fileField: "file", fileData: data, filename: "photo.jpg",
                        mimeType: mime, as: PhotoDTO.self)
                    appendPhoto(photo, jobId: jobId)
                }
            } catch {
                remaining.append(action)
            }
        }
        pendingActions = remaining
        setSyncState(pendingActions.isEmpty ? .synced : .queued(pendingActions.count))
    }

    // Anna's account is the offline-scenario stand-in.
    private var isOfflineSim: Bool { user?.email == "anna@firma.pl" }

    private func applyOfflineSimulationFlag() {
        if isOfflineSim {
            setSyncState(.offline)
        } else if pendingActions.isEmpty {
            setSyncState(.synced)
        }
    }
}

// MARK: - TokenSource

extension AppStore: TokenSource {
    nonisolated var accessToken: String? {
        get async { await MainActor.run { cachedAccessToken } }
    }

    nonisolated func handleUnauthorized() async -> String? {
        guard let refresh = await MainActor.run(body: { keychain.load(.refreshToken) }) else { return nil }
        do {
            let res: RefreshResponse = try await api.send(
                .post, "/auth/refresh",
                body: ["refreshToken": refresh],
                as: RefreshResponse.self)
            try await MainActor.run {
                try keychain.save(res.accessToken, for: .accessToken)
                try keychain.save(res.refreshToken, for: .refreshToken)
                cachedAccessToken = res.accessToken
            }
            return res.accessToken
        } catch {
            await MainActor.run {
                keychain.clearAll()
                cachedAccessToken = nil
                phase = .loggedOut
            }
            return nil
        }
    }
}
