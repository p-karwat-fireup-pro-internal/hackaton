import SwiftUI

struct TodayView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let pending  = store.jobs.filter { $0.status != .done }
        let done     = store.jobs.filter { $0.status == .done }
        let spotlight = pickSpotlight(in: pending)
        let restOfDay = spotlight.map { s in pending.filter { $0.id != s.id } } ?? pending
        let allDone = pending.isEmpty

        VStack(spacing: 0) {
            TopBar(date: Date(), syncState: store.syncState)

            ScrollView {
                VStack(spacing: 16) {
                    if store.pendingNewJobBanner {
                        NewJobBanner(onAccept: store.acceptNewJob,
                                     onDismiss: store.dismissNewJobBanner)
                    }

                    if allDone {
                        AllDoneSummary(count: done.count)
                            .padding(.horizontal, 16)
                    } else if let spotlight {
                        NavigationLink(value: Route.jobDetail(jobId: spotlight.id)) {
                            SpotlightCard(
                                job: spotlight,
                                spotlightLabel: spotlightLabelText(
                                    for: spotlight,
                                    pendingCount: pending.count,
                                    doneCount: done.count
                                ),
                                showOfflineNote: store.syncState == .offline
                            )
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                    }

                    if !restOfDay.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            sectionHeader(title: "Reszta dnia", count: restOfDay.count)
                                .padding(.top, 12)

                            ForEach(Array(restOfDay.enumerated()), id: \.element.id) { idx, job in
                                if idx > 0 {
                                    Rectangle()
                                        .fill(Color.borderSoft)
                                        .frame(height: 1)
                                        .padding(.leading, 20)
                                }
                                NavigationLink(value: Route.jobDetail(jobId: job.id)) {
                                    JobRow(job: job)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if !done.isEmpty {
                        DoneAccordion(doneJobs: done)
                            .padding(.top, 8)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color.cream)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomCta(spotlight: spotlight, allDone: allDone)
            }
        }
    }

    // MARK: - Spotlight selection

    /// Prefer an in-progress job; otherwise the first pending one. Mirrors
    /// `pickSpotlight` in `app/src/screens/TodayScreen.tsx`.
    private func pickSpotlight(in pending: [JobDTO]) -> JobDTO? {
        if let inProgress = pending.first(where: { $0.status == .in_progress }) {
            return inProgress
        }
        return pending.first
    }

    /// Mirrors `spotlightLabel` in `app/src/screens/TodayScreen.tsx`.
    private func spotlightLabelText(
        for spotlight: JobDTO,
        pendingCount: Int,
        doneCount: Int
    ) -> String {
        if spotlight.status == .in_progress { return "Trwa zlecenie" }
        if doneCount == 0                   { return "Pierwsze zlecenie" }
        if pendingCount == 1                { return "Ostatnie zlecenie" }
        return "Następne zlecenie"
    }

    // MARK: - Bottom CTA

    @ViewBuilder
    private func bottomCta(spotlight: JobDTO?, allDone: Bool) -> some View {
        if allDone {
            // No actionable next step from this surface — the rest of the day
            // is closed. We still surface a passive "Pokaż następne" so the
            // bottom of the screen stays predictable.
            BottomCTA(title: "Pokaż następne",
                      iconName: .chevronRight,
                      enabled: false) {}
        } else if let spotlight {
            let title = spotlight.status == .in_progress ? "Otwórz zlecenie" : "Rozpocznij"
            let icon: IconName = spotlight.status == .in_progress ? .chevronRight : .play
            NavigationLink(value: Route.jobDetail(jobId: spotlight.id)) {
                BottomCTAShape(title: title, iconName: icon)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                if spotlight.status == .pending {
                    Task { await store.startJob(spotlight.id) }
                }
            })
        }
    }

    // MARK: - Section header

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.sans(.bold, size: 15))
                .foregroundStyle(Color.titleInk)
            Text("\(count)")
                .font(.sans(.medium, size: 13))
                .foregroundStyle(Color.muted)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

/// Rounded summary card shown when every assigned job is closed. Mirrors
/// `AllDoneSummary` in `app/src/screens/TodayScreen.tsx` — operational tone,
/// no celebration copy.
private struct AllDoneSummary: View {
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle().fill(Color.statusDone)
                IconView(name: .check, size: 26).foregroundStyle(Color.inkOnSignal)
            }
            .frame(width: 48, height: 48)

            Text("Wszystko zrobione.")
                .font(.sans(.bold, size: 28))
                .foregroundStyle(Color.titleInk)
                .accessibilityAddTraits(.isHeader)

            Text(count == 1
                 ? "1 zlecenie ukończone dziś."
                 : count < 5
                    ? "\(count) zlecenia ukończone dziś."
                    : "\(count) zleceń ukończonych dziś.")
                .font(.bodyText)
                .foregroundStyle(Color.bodyInk)

            Text("Najbliższe: jutro od 8:00. Skontaktuj się z dyspozytorem, jeśli potrzebujesz dodatkowych zleceń.")
                .font(.sans(.medium, size: 14))
                .foregroundStyle(Color.muted)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.cardPad)
        .background(Color.mist, in: RoundedRectangle(cornerRadius: Radius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.borderSoft, lineWidth: 1)
        )
    }
}
