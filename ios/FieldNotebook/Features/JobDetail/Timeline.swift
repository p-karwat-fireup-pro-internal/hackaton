import SwiftUI

/// "Postęp" — three-step vertical timeline with a connecting rail.
/// Mirrors `Timeline` in `app/src/screens/JobDetailScreen.tsx`.
struct Timeline: View {
    let job: JobDTO
    let photoCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill(Color.borderSoft).frame(height: 1)
                .padding(.bottom, 16)
            SectionLabel(text: "Postęp").padding(.bottom, 14)
            ZStack(alignment: .topLeading) {
                rail
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(steps.indices, id: \.self) { idx in
                        row(steps[idx], isCurrent: idx == 1 && job.status == .in_progress)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private struct Step {
        let label: String
        let done: Bool
        let subtitle: String?
    }

    private var steps: [Step] {
        let started = job.status != .pending
        let finished = job.status == .done
        let inProgressSubtitle: String = {
            if job.status == .pending { return "Czeka na rozpoczęcie" }
            if finished {
                let label = photoCount == 1 ? "zdjęcie" : "zdjęć"
                return "Zakończone, \(photoCount) \(label)"
            }
            return "W trakcie"
        }()
        let finishedSubtitle = finished
            ? "Zatwierdzone w aplikacji"
            : "Wymaga zdjęcia i opisu"
        return [
            Step(label: "Przydzielone", done: true, subtitle: job.scheduledWindow),
            Step(label: "Rozpoczęte", done: started, subtitle: inProgressSubtitle),
            Step(label: "Ukończone", done: finished, subtitle: finishedSubtitle),
        ]
    }

    private var rail: some View {
        Rectangle()
            .fill(Color.borderSoft)
            .frame(width: 2)
            .padding(.leading, 10)
            .padding(.top, 12)
            .padding(.bottom, 12)
    }

    private func row(_ step: Step, isCurrent: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            marker(done: step.done, isCurrent: isCurrent)
            VStack(alignment: .leading, spacing: 2) {
                Text(step.label)
                    .font(.sans(.semibold, size: 15))
                    .foregroundStyle(markerLabelColor(done: step.done, isCurrent: isCurrent))
                if let subtitle = step.subtitle {
                    Text(subtitle)
                        .font(.sans(.medium, size: 13))
                        .foregroundStyle(Color.muted)
                }
            }
            .padding(.top, 1)
        }
    }

    @ViewBuilder
    private func marker(done: Bool, isCurrent: Bool) -> some View {
        ZStack {
            if done {
                Circle().fill(Color.statusDone)
                IconView(name: .check, size: 12).foregroundStyle(Color.inkOnSignal)
            } else if isCurrent {
                Circle().fill(Color.signal)
                Circle().fill(Color.inkOnSignal).frame(width: 8, height: 8)
            } else {
                Circle().fill(Color.cream)
                Circle().stroke(Color.borderHair, lineWidth: 2)
            }
        }
        .frame(width: 22, height: 22)
    }

    private func markerLabelColor(done: Bool, isCurrent: Bool) -> Color {
        if done { return Color.titleInk }
        if isCurrent { return Color.signalDark }
        return Color.muted
    }
}
