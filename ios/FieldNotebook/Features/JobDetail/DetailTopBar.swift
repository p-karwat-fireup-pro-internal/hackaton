import SwiftUI

struct DetailTopBar: View {
    let onBack: () -> Void
    let ticketId: String
    let syncState: AppStore.SyncState

    var body: some View {
        HStack {
            Button(action: onBack) {
                IconView(name: .chevronLeft)
                    .foregroundStyle(Color.bodyInk)
                    .frame(width: Spacing.tapMin, height: Spacing.tapMin)
            }
            Spacer()
            Text(ticketId).font(.mono(.medium, size: 14)).foregroundStyle(Color.muted)
            Spacer()
            SyncIndicator(state: syncState)
                .padding(.trailing, 12)
        }
        .frame(height: Spacing.topBarHeight)
        .background(Color.cream)
        .overlay(alignment: .bottom) { Rectangle().fill(Color.borderSoft).frame(height: 1) }
    }
}
