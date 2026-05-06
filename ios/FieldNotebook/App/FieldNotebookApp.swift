import SwiftUI

@main
struct FieldNotebookApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .task { await store.bootstrap() }
        }
    }
}

struct RootView: View {
    @Environment(AppStore.self) private var store
    @State private var path: [Route] = []

    var body: some View {
        switch store.phase {
        case .bootstrapping:
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.cream)
        case .loggedOut:
            LoginView()
        case .lockedOut, .ready:
            BiometricGateView {
                NavigationStack(path: $path) {
                    TodayView()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Wyloguj") { Task { await store.logout() } }
                                    .font(.labelSmall)
                            }
                        }
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .jobDetail(let id): JobDetailView(jobId: id)
                            case .capture(let id):   CaptureView(jobId: id)
                            }
                        }
                }
            }
        }
    }
}
