import SwiftUI

/// "Kontakt na miejscu" — initials avatar + name + phone, with a 64 pt
/// signal-blue circular call button on the right. The call button is the
/// single ergonomic affordance a technician needs in the field; tapping it
/// hands off to the system phone app via the `tel:` scheme.
struct ContactBlock: View {
    let job: JobDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill(Color.borderSoft).frame(height: 1)
                .padding(.bottom, 16)
            SectionLabel(text: "Kontakt na miejscu")
                .padding(.bottom, 12)

            HStack(alignment: .center, spacing: 14) {
                avatar
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.contactName ?? "—")
                        .font(.sans(.semibold, size: 16))
                        .foregroundStyle(Color.titleInk)
                    if let phone = job.contactPhone {
                        Text(phone)
                            .font(.mono(.regular, size: 14))
                            .foregroundStyle(Color.muted)
                    }
                }
                Spacer()
                if let phone = job.contactPhone {
                    callButton(phone: phone)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private var avatar: some View {
        let initials = (job.contactName ?? "")
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map { String($0) } }
            .joined()
            .uppercased()
        return ZStack {
            Circle().fill(Color.mistDeep)
            Text(initials.isEmpty ? "—" : initials)
                .font(.sans(.bold, size: 16))
                .foregroundStyle(Color.bodyInk)
        }
        .frame(width: 48, height: 48)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func callButton(phone: String) -> some View {
        let cleaned = phone.filter { !$0.isWhitespace }
        Button(action: { openTel(cleaned) }) {
            ZStack {
                Circle().fill(Color.signal)
                IconView(name: .phone, size: 22).foregroundStyle(Color.inkOnSignal)
            }
            .frame(width: 64, height: 64)
        }
        .accessibilityLabel("Zadzwoń do \(job.contactName ?? "kontaktu")")
    }

    private func openTel(_ phone: String) {
        guard let url = URL(string: "tel:\(phone)") else { return }
        UIApplication.shared.open(url)
    }
}
