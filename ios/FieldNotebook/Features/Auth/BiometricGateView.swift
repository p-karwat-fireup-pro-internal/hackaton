import SwiftUI

struct BiometricGateView<Content: View>: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppStore.self) private var store
    @State private var unlocked = false
    @State private var biometricUnavailable = false
    @State private var auth = BiometricAuth()
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        Group {
            if unlocked {
                content()
            } else {
                lockedView
            }
        }
        .task { await tryUnlock() }
        .onChange(of: scenePhase) { _, new in
            if new == .background { unlocked = false }
            if new == .active && !unlocked { Task { await tryUnlock() } }
        }
    }

    private var lockedView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.mistDeep)
                    IconView(name: .wrench, size: 32).foregroundStyle(Color.bodyInk)
                }
                .frame(width: 72, height: 72)

                Text("Field Notebook")
                    .font(.headline).foregroundStyle(Color.titleInk)
                Text(biometricUnavailable
                     ? "Zaloguj się hasłem aplikacji, żeby kontynuować."
                     : "Aplikacja zablokowana. Odblokuj, żeby zobaczyć zlecenia.")
                    .font(.bodyText).foregroundStyle(Color.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            BottomCTA(title: ctaTitle, iconName: ctaIcon) {
                if biometricUnavailable {
                    Task { await store.logout() }
                } else {
                    Task { await tryUnlock() }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cream)
    }

    private var ctaTitle: String {
        biometricUnavailable ? "Zaloguj hasłem" : "Odblokuj"
    }

    private var ctaIcon: IconName {
        biometricUnavailable ? .chevronRight : .play
    }

    private func tryUnlock() async {
        let r = await auth.authenticate()
        switch r {
        case .success: unlocked = true
        case .unavailable:
            biometricUnavailable = true
            #if targetEnvironment(simulator)
            unlocked = true
            #endif
        case .failed, .userCancelled: break
        }
    }
}
