import SwiftUI

struct DoneAccordion: View {
    let doneJobs: [JobDTO]
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeOut(duration: 0.2)) { expanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.statusDone)
                        IconView(name: .check, size: 14).foregroundStyle(Color.inkOnSignal)
                    }
                    .frame(width: 24, height: 24)

                    Text(headerLabel)
                        .font(.sans(.semibold, size: 15))
                        .foregroundStyle(Color.titleInk)
                    Spacer()
                    IconView(name: .chevronRight, size: 16)
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                        .foregroundStyle(Color.muted)
                }
                .padding(.horizontal, 20)
                .frame(minHeight: Spacing.tapMin)
            }
            .buttonStyle(.plain)
            .overlay(alignment: .top) {
                Rectangle().fill(Color.borderSoft).frame(height: 1)
            }

            if expanded {
                LazyVStack(spacing: 0) {
                    ForEach(Array(doneJobs.enumerated()), id: \.element.id) { idx, job in
                        if idx > 0 {
                            Rectangle()
                                .fill(Color.borderSoft)
                                .frame(height: 1)
                                .padding(.leading, 20)
                        }
                        JobRow(job: job)
                    }
                }
            }
        }
        .background(Color.cream)
    }

    private var headerLabel: String {
        let count = doneJobs.count
        if count == 1 { return "1 ukończone wcześniej" }
        if count < 5  { return "\(count) ukończone wcześniej" }
        return "\(count) ukończonych wcześniej"
    }
}
