import SwiftUI

struct LoginView: View {
    @Environment(AppStore.self) private var store
    @State private var email = ""
    @State private var password = ""
    @State private var error: LoginError?
    @State private var lockedUntil: Date?
    @State private var submitting = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable { case email, password }

    enum LoginError: Equatable {
        case api(APIError)
        case keychain
        case unknown
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Field Notebook")
                .font(.display).foregroundStyle(Color.titleInk)
                .padding(.top, 32)
            Text("Zaloguj się, żeby zobaczyć dzisiejsze zlecenia.")
                .font(.bodyText).foregroundStyle(Color.bodyInk)

            VStack(spacing: 12) {
                TextField("E-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .padding(14)
                    .background(Color.mist, in: RoundedRectangle(cornerRadius: Radius.md))

                SecureField("Hasło", text: $password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { Task { await submit() } }
                    .padding(14)
                    .background(Color.mist, in: RoundedRectangle(cornerRadius: Radius.md))
            }
            .font(.bodyText)
            .padding(.top, 8)

            if let error {
                Text(message(for: error))
                    .font(.labelSmall).foregroundStyle(Color.statusUrgent)
            }

            Spacer()

            #if DEBUG_LOCAL
            Text("Konta testowe: zobacz README backendu.")
                .font(.labelSmall).foregroundStyle(Color.muted)
            #endif
        }
        .padding(.horizontal, 20)
        .background(Color.cream)
        .safeAreaInset(edge: .bottom) {
            BottomCTA(title: submitting ? "Logowanie…" : "Zaloguj",
                      iconName: submitting ? nil : .chevronRight,
                      enabled: !submitting && !email.isEmpty && !password.isEmpty,
                      loading: submitting) {
                Task { await submit() }
            }
        }
    }

    private func submit() async {
        submitting = true
        defer { submitting = false }
        error = nil
        do {
            try await store.login(email: email, password: password)
        } catch let e as APIError {
            self.error = .api(e)
            if case .accountLocked(let until) = e { lockedUntil = until }
        } catch is KeychainError {
            self.error = .keychain
        } catch {
            self.error = .unknown
        }
    }

    private func message(for e: LoginError) -> String {
        switch e {
        case .api(let apiError):
            if case .accountLocked(let until) = apiError {
                let minutes = max(0, Int(until.timeIntervalSinceNow / 60))
                return "Konto zablokowane (~\(minutes) min)."
            }
            return apiError.userMessagePolish
        case .keychain:
            return "Nie udało się zapisać sesji w pamięci urządzenia. Spróbuj ponownie."
        case .unknown:
            return "Coś poszło nie tak. Spróbuj ponownie."
        }
    }
}
