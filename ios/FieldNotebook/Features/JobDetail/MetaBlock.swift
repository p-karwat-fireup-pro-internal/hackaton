import SwiftUI

/// "Realizacja" — three rows with logistics meta. Sits below `DescriptionBlock`
/// with a hairline divider separating it from the description.
struct MetaBlock: View {
    let job: JobDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill(Color.borderSoft).frame(height: 1)
                .padding(.bottom, 16)
            SectionLabel(text: "Realizacja")
                .padding(.bottom, 12)
            VStack(spacing: 0) {
                MetaRow(icon: .clock, label: "Okno czasowe", value: job.scheduledWindow, monospaced: true)
                if let travel = job.travelTimeMin {
                    MetaRow(icon: .mapPin, label: "Dojazd", value: "~ \(travel) min jazdy")
                }
                MetaRow(icon: .refreshCw, label: "Czas pracy", value: "~ \(job.estimatedDurationMin) min")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

struct MetaRow: View {
    let icon: IconName
    let label: String
    let value: String
    var monospaced: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle().fill(Color.mist)
                IconView(name: icon, size: 14).foregroundStyle(Color.muted)
            }
            .frame(width: 32, height: 32)

            Text(label)
                .font(.sans(.medium, size: 14))
                .foregroundStyle(Color.muted)

            Spacer()

            Text(value)
                .font(monospaced ? .mono(.medium, size: 15) : .sans(.semibold, size: 15))
                .foregroundStyle(Color.bodyInk)
        }
        .padding(.vertical, 10)
    }
}
