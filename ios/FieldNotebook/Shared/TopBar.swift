import SwiftUI

struct TopBar: View {
    let date: Date
    let syncState: AppStore.SyncState

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mój dzień")
                    .font(.sans(.bold, size: 28))
                    .foregroundStyle(Color.titleInk)
                    .accessibilityAddTraits(.isHeader)
                Text(Self.formatDate(date))
                    .font(.sans(.medium, size: 14))
                    .foregroundStyle(Color.muted)
            }
            Spacer()
            SyncIndicator(state: syncState)
                .padding(.bottom, 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.cream)
    }

    /// Mirrors `formatDate` in `app/src/components/TopBar.tsx`: short Polish
    /// weekday + day + short Polish month (e.g. "Wt, 7 maj"). Uses fixed
    /// arrays rather than `DateFormatter` so the abbreviations match the
    /// prototype byte-for-byte and don't depend on the device locale.
    private static let dayShort = ["Nd", "Pn", "Wt", "Śr", "Cz", "Pt", "Sb"]
    private static let monthShort = [
        "sty", "lut", "mar", "kwi", "maj", "cze",
        "lip", "sie", "wrz", "paź", "lis", "gru",
    ]

    private static func formatDate(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Sunday — matches JS `Date.getDay()`
        let components = calendar.dateComponents([.weekday, .day, .month], from: date)
        let weekdayIdx = (components.weekday ?? 1) - 1
        let monthIdx = (components.month ?? 1) - 1
        let day = components.day ?? 1
        return "\(dayShort[weekdayIdx]), \(day) \(monthShort[monthIdx])"
    }
}
