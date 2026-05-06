import SwiftUI

struct JobDetailView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let jobId: String

    var body: some View {
        let job = store.jobs.first(where: { $0.id == jobId })
        VStack(spacing: 0) {
            DetailTopBar(onBack: { dismiss() },
                         ticketId: job?.ticketId ?? "—",
                         syncState: store.syncState)
            if let job {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        StatusBadge(status: job.status)
                        Text(job.address).font(.display).foregroundStyle(Color.titleInk)
                        if let unit = job.unit {
                            Text(unit).font(.bodyLarge).foregroundStyle(Color.bodyInk)
                        }
                        Text(job.description).font(.bodyText).foregroundStyle(Color.bodyInk)

                        InfoRow(label: "Okno", value: job.scheduledWindow)
                        InfoRow(label: "Czas pracy", value: "\(job.estimatedDurationMin) min")
                        if let n = job.contactName { InfoRow(label: "Kontakt", value: n) }
                        if let p = job.contactPhone { InfoRow(label: "Telefon", value: p) }
                    }
                    .padding(20)
                }
                .background(Color.cream)
                .safeAreaInset(edge: .bottom) {
                    cta(for: job)
                }
            } else {
                Text("Zlecenie nie istnieje.").padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func cta(for job: JobDTO) -> some View {
        switch job.status {
        case .pending:
            BottomCTA(title: "Zacznij zlecenie") {
                Task { await store.startJob(job.id) }
            }
        case .in_progress:
            NavigationLink(value: Route.capture(jobId: job.id)) {
                Text("Dodaj zdjęcie")
                    .font(.sans(.semibold, size: 17))
                    .foregroundStyle(Color.inkOnSignal)
                    .frame(maxWidth: .infinity, minHeight: Spacing.ctaHeight)
                    .background(Color.signal, in: RoundedRectangle(cornerRadius: Radius.lg))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
        case .done:
            EmptyView()
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.labelSmall).foregroundStyle(Color.muted)
            Text(value).font(.bodyText).foregroundStyle(Color.bodyInk)
        }
    }
}
