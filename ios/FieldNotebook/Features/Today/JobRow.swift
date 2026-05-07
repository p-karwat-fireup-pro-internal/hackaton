import SwiftUI

struct JobRow: View {
    let job: JobDTO

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            categoryAvatar
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                categoryRow
                    .padding(.bottom, 2)

                Text(job.addressWithUnit)
                    .font(.sans(.semibold, size: 17))
                    .foregroundStyle(isDone ? Color.bodyInk : Color.titleInk)
                    .strikethrough(isDone, color: Color.bodyInk)
                    .lineLimit(1)

                Text(job.description)
                    .font(.sans(.regular, size: 14))
                    .foregroundStyle(Color.bodyInk)
                    .lineLimit(1)
                    .padding(.top, 2)

                statusRow
                    .padding(.top, 8)
            }

            IconView(name: .chevronRight, size: 18)
                .foregroundStyle(Color.borderHair)
                .padding(.top, 18)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .opacity(isDone ? 0.55 : 1)
        .frame(minHeight: Spacing.rowHeight, alignment: .top)
    }

    /// 40 pt circular badge — neutral mistDeep for normal jobs, urgentSoft with
    /// alert-triangle for urgent ones, statusDoneSoft with check for completed.
    /// This is the visual anchor PRODUCT.md needs: a technician scanning the
    /// list with one hand should see categorisation before reading any text.
    @ViewBuilder
    private var categoryAvatar: some View {
        ZStack {
            Circle().fill(avatarFill)
            IconView(name: avatarIcon, size: 18)
                .foregroundStyle(avatarTint)
        }
        .frame(width: 40, height: 40)
    }

    private var avatarFill: Color {
        if isDone   { return Color.statusDoneSoft }
        if isUrgent { return Color.statusUrgentSoft }
        return Color.mistDeep
    }

    private var avatarIcon: IconName {
        if isDone   { return .check }
        if isUrgent { return .alertTriangle }
        return categoryIcon(for: job.category)
    }

    private var avatarTint: Color {
        if isDone   { return Color.statusDone }
        if isUrgent { return Color.statusUrgent }
        return Color.bodyInk
    }

    private var categoryRow: some View {
        HStack(spacing: 6) {
            Text(categoryLabel(for: job.category))
                .font(.sans(.semibold, size: 12))
                .foregroundStyle(Color.muted)
            Spacer()
            Text(job.ticketId)
                .font(.mono(.regular, size: 11))
                .foregroundStyle(Color.muted)
        }
    }

    private var statusRow: some View {
        HStack(spacing: 10) {
            Text(statusText)
                .font(.sans(.semibold, size: 13))
                .foregroundStyle(statusColor)
            Circle()
                .fill(Color.borderHair)
                .frame(width: 3, height: 3)
            Text(job.scheduledWindow)
                .font(.mono(.regular, size: 13))
                .foregroundStyle(Color.muted)
        }
    }

    private var isUrgent: Bool {
        job.priority == .urgent && job.status != .done
    }

    private var isDone: Bool { job.status == .done }

    private var statusText: String {
        isUrgent ? "Pilne" : job.status.polishLabel
    }

    private var statusColor: Color {
        if isUrgent { return Color.statusUrgent }
        if isDone   { return Color.statusDone }
        return Color.muted
    }
}
