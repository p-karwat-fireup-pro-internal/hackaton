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
                    VStack(alignment: .leading, spacing: 0) {
                        HeroBlock(job: job)
                            .padding(.horizontal, 16)
                            .padding(.top, 4)
                        DescriptionBlock(job: job)
                            .padding(.top, 24)
                        MetaBlock(job: job)
                            .padding(.top, 28)
                        if job.contactName != nil {
                            ContactBlock(job: job)
                                .padding(.top, 28)
                        }
                        Timeline(job: job, photoCount: store.photosByJob[job.id]?.count ?? 0)
                            .padding(.top, 28)
                        if job.status != .pending {
                            PhotosBlock(
                                photos: store.photosByJob[job.id] ?? [],
                                canAdd: job.status == .in_progress
                            )
                            .padding(.top, 28)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .background(Color.cream)
                .safeAreaInset(edge: .bottom) {
                    cta(for: job)
                }
            } else {
                missingJobView
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func cta(for job: JobDTO) -> some View {
        switch job.status {
        case .pending:
            BottomCTA(title: "Rozpocznij zlecenie", iconName: .play) {
                Task { await store.startJob(job.id) }
            }
        case .in_progress:
            let label = (store.photosByJob[job.id]?.isEmpty ?? true)
                ? "Dodaj raport i zakończ"
                : "Zakończ zlecenie"
            NavigationLink(value: Route.capture(jobId: job.id)) {
                BottomCTAShape(title: label, iconName: .check)
            }
            .buttonStyle(.plain)
        case .done:
            EmptyView()
        }
    }

    private var missingJobView: some View {
        VStack(spacing: 16) {
            IconView(name: .alertTriangle, size: 32).foregroundStyle(Color.statusUrgent)
            Text("Zlecenie zniknęło z listy")
                .font(.titleText).foregroundStyle(Color.titleInk)
            Text("Mogło zostać przepisane. Wróć do listy, żeby zobaczyć aktualne zadanie.")
                .font(.bodyText).foregroundStyle(Color.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 48)
        .background(Color.cream)
        .safeAreaInset(edge: .bottom) {
            BottomCTA(title: "Wróć do listy", iconName: .chevronLeft) {
                dismiss()
            }
        }
    }
}

/// `BottomCTA` siedzi na `Button`, więc owinięcie w `NavigationLink` da nam dwa
/// klikalne warstwy. Ten kształt ma identyczny wygląd, ale bez wewnętrznego
/// `Button` — używaj go gdy chcesz, żeby nawigacja była głównym handlerem.
struct BottomCTAShape: View {
    let title: String
    var iconName: IconName?

    var body: some View {
        HStack(spacing: 8) {
            if let iconName {
                IconView(name: iconName, size: 18).foregroundStyle(Color.inkOnSignal)
            }
            Text(title)
                .font(.sans(.semibold, size: 17))
                .foregroundStyle(Color.inkOnSignal)
        }
        .frame(maxWidth: .infinity, minHeight: Spacing.ctaHeight)
        .background(Color.signal, in: RoundedRectangle(cornerRadius: Radius.lg))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.cream)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.borderSoft).frame(height: 1)
        }
    }
}
