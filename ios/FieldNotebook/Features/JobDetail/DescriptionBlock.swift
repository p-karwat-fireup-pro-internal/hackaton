import SwiftUI

/// "Opis zgłoszenia" — plain section with label + body. Lives outside the hero
/// card so the body text gets the full screen width for line-length comfort.
struct DescriptionBlock: View {
    let job: JobDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "Opis zgłoszenia")
            Text(job.description)
                .font(.bodyText)
                .foregroundStyle(Color.bodyInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

/// Small uppercase-free label used as section header throughout the detail
/// screen. Sentence case enforced — DESIGN.md forbids uppercase chip text.
struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.sans(.semibold, size: 13))
            .foregroundStyle(Color.muted)
    }
}
