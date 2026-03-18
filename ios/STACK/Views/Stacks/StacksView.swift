import SwiftUI

struct StacksView: View {
    let store: StackStore
    @State private var selectedMilestone: Int?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Milestone.allDays, id: \.self) { days in
                        let earned = store.currentDays >= days
                        if earned {
                            Button {
                                selectedMilestone = days
                            } label: {
                                earnedRow(days: days)
                            }
                        } else {
                            lockedRow(days: days)
                        }

                        if days != Milestone.allDays.last {
                            StackTheme.separator
                                .frame(height: 0.5)
                                .padding(.leading, 80)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .background(StackTheme.background)
            .navigationTitle("Stacks")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedMilestone) { days in
                StackCardView(store: store, milestoneDays: days)
            }
        }
    }

    private func earnedRow(days: Int) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color(hex: "C8A96E"), lineWidth: 1.5)
                    .frame(width: 40, height: 40)

                Text(Milestone.shortLabel(for: days))
                    .font(.system(size: 15, weight: .thin))
                    .foregroundStyle(Color(hex: "C8A96E"))
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(Milestone.label(for: days) ?? "")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(StackTheme.primaryText)

                    if !store.receivedRelayMilestoneDays.contains(days) {
                        Circle()
                            .fill(Color(hex: "C8A96E"))
                            .frame(width: 4, height: 4)
                    }
                }

                if let info = store.earnedDate(for: days) {
                    Text("\(StackDateFormatter.string(from: info.date)) · Chapter \(info.chapter.chapterNumber)")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(StackTheme.tertiaryText)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }

    private func lockedRow(days: Int) -> some View {
        HStack(spacing: 16) {
            Circle()
                .stroke(StackTheme.ghost, lineWidth: 1.5)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(Milestone.label(for: days) ?? "")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(StackTheme.tertiaryText)

                let remaining = Milestone.daysUntil(from: store.currentDays, to: days)
                Text("In \(remaining) days")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(StackTheme.ghost)
            }

            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .allowsHitTesting(false)
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}
