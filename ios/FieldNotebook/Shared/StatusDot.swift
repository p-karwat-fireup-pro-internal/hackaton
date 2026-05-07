import SwiftUI

struct StatusDot: View {
    let status: JobStatus
    var body: some View {
        Circle()
            .fill(status.foreground)
            .frame(width: 8, height: 8)
            .accessibilityHidden(true)
    }
}
