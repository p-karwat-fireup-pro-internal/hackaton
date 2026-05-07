import SwiftUI

struct StatusBadge: View {
    let status: JobStatus

    var body: some View {
        HStack(spacing: 6) {
            IconView(name: status.icon, size: 14)
            Text(status.polishLabel).font(.labelSmall)
        }
        .foregroundStyle(status.foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(status.softBackground, in: RoundedRectangle(cornerRadius: Radius.sm))
        .accessibilityLabel(status.polishLabel)
    }
}
