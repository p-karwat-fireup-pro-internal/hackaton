import SwiftUI

/// Big rounded card at the top of the detail screen — category chip + display
/// address + optional district. Mirrors `HeroBlock` in
/// `app/src/screens/JobDetailScreen.tsx`.
struct HeroBlock: View {
    let job: JobDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            categoryRow
                .padding(.bottom, 12)
            address
            if let district = job.district {
                Text(district)
                    .font(.sans(.medium, size: 15))
                    .foregroundStyle(Color.muted)
                    .padding(.top, 4)
            }
        }
        .padding(Spacing.cardPad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mist, in: RoundedRectangle(cornerRadius: Radius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.borderSoft, lineWidth: 1)
        )
    }

    private var categoryRow: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(Color.mistDeep)
                IconView(name: categoryIcon(for: job.category), size: 15)
                    .foregroundStyle(Color.bodyInk)
            }
            .frame(width: 28, height: 28)

            Text(categoryLabel(for: job.category))
                .font(.sans(.semibold, size: 13))
                .foregroundStyle(Color.muted)
        }
    }

    private var address: some View {
        let suffix = job.unit.map { " " + $0 } ?? ""
        return (
            Text(job.address)
                .font(.sans(.bold, size: 30))
                .foregroundStyle(Color.titleInk)
            + Text(suffix)
                .font(.sans(.medium, size: 30))
                .foregroundStyle(Color.bodyInk)
        )
        .lineSpacing(2)
    }
}
