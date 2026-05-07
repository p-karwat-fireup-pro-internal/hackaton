import SwiftUI

/// Pojedynczy sygnałowo-niebieski banner sygnalizujący nowo doczepione zlecenie.
/// Cały banner jest klikalny (akceptacja/podgląd); długie przyciśnięcie ujawnia
/// dyskretny dismiss. Inspiracja: `NewJobBanner` z prototypu RN.
struct NewJobBanner: View {
    let onAccept: () -> Void
    let onDismiss: () -> Void
    var count: Int = 1

    var body: some View {
        Button(action: onAccept) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.inkOnSignal.opacity(0.18))
                    IconView(name: .plus, size: 18).foregroundStyle(Color.inkOnSignal)
                }
                .frame(width: 32, height: 32)

                Text(label)
                    .font(.sans(.semibold, size: 16))
                    .foregroundStyle(Color.inkOnSignal)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Text("Pokaż")
                    .font(.sans(.semibold, size: 14))
                    .foregroundStyle(Color.inkOnSignal.opacity(0.86))
                IconView(name: .chevronRight, size: 16)
                    .foregroundStyle(Color.inkOnSignal.opacity(0.86))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: Spacing.tapMin)
            .background(Color.signal, in: RoundedRectangle(cornerRadius: Radius.lg))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .accessibilityAction(named: "Odrzuć", onDismiss)
    }

    private var label: String {
        count == 1 ? "+1 nowe zlecenie" : "+\(count) nowe zlecenia"
    }
}
