import SwiftUI

/// Sticky primary action at the bottom of the screen.
///
/// `DESIGN.md` reserves the bottom 60% of every screen for primary action and
/// requires ≥64 pt height. Every screen-level CTA in the app routes through
/// this component so the signal-blue accent reads as one consistent shape.
struct BottomCTA: View {
    let title: String
    var iconName: IconName?
    var enabled: Bool = true
    var loading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color.inkOnSignal)
                } else if let iconName {
                    IconView(name: iconName, size: 18)
                        .foregroundStyle(Color.inkOnSignal)
                }
                Text(title)
                    .font(.sans(.semibold, size: 17))
                    .foregroundStyle(Color.inkOnSignal)
            }
            .frame(maxWidth: .infinity, minHeight: Spacing.ctaHeight)
            .background(background, in: RoundedRectangle(cornerRadius: Radius.lg))
        }
        .disabled(!enabled || loading)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.cream)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.borderSoft).frame(height: 1)
        }
    }

    private var background: Color {
        if !enabled || loading { return Color.signal.opacity(0.4) }
        return Color.signal
    }
}
