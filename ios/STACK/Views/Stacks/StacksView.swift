import SwiftUI

struct StacksView: View {
    let store: StackStore
    @State private var selectedMilestone: Int?
    @AppStorage("lastSeenEarnedMilestone") private var lastSeenEarnedMilestone: Int = 0
    @State private var newlyEarnedMilestone: Int? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Stacks")
                    .font(.system(size: 34, weight: .light))
                    .foregroundStyle(StackTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

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
            .navigationTitle("")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedMilestone) { days in
                StackCardView(store: store, milestoneDays: days)
            }
            .onAppear {
                // Detect if a new milestone was earned since last visit
                let currentDays = store.currentDays
                if currentDays > lastSeenEarnedMilestone {
                    // Find the highest milestone just crossed
                    let justEarned = Milestone.allDays.last { $0 <= currentDays && $0 > lastSeenEarnedMilestone }
                    if let earned = justEarned {
                        newlyEarnedMilestone = earned
                        // Clear after the bounce completes
                        Task {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            newlyEarnedMilestone = nil
                        }
                    }
                    lastSeenEarnedMilestone = currentDays
                }
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
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(hex: "C8A96E"))
            }
            .frame(width: 40, height: 40)
            .scaleEffect(newlyEarnedMilestone == days ? 1.12 : 1.0)
            .animation(
                newlyEarnedMilestone == days
                    ? .spring(duration: 0.3, bounce: 0.5).repeatCount(2, autoreverses: true)
                    : .default,
                value: newlyEarnedMilestone
            )

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(Milestone.label(for: days) ?? "")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StackTheme.primaryText)

                    if !store.receivedRelayDays.contains(days) {
                        Circle()
                            .fill(StackTheme.primaryText)
                            .frame(width: 4, height: 4)
                    }
                }

                if let info = store.earnedDate(for: days) {
                    Text("\(StackDateFormatter.string(from: info.date)) · Chapter \(info.chapter.chapterNumber)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(StackTheme.tertiaryText)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .regular))
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
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(StackTheme.tertiaryText)

                let remaining = Milestone.daysUntil(from: store.currentDays, to: days)
                Text("In \(remaining) days")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(StackTheme.tertiaryText)
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
