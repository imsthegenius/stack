import SwiftUI

struct StacksView: View {
    let store: StackStore
    @State private var selectedMilestone: Int?
    @AppStorage("lastSeenEarnedMilestone") private var lastSeenEarnedMilestone: Int = 0
    @State private var newlyEarnedMilestone: Int? = nil
    @State private var listAppeared: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Stacks")
                    .font(StackTypography.title)
                    .foregroundStyle(StackTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                LazyVStack(spacing: 0) {
                    ForEach(Array(Milestone.allDays.enumerated()), id: \.element) { index, days in
                        let earned = store.currentDays >= days
                        if earned {
                            Button {
                                StackHaptics.cta()
                                selectedMilestone = days
                            } label: {
                                earnedRow(days: days, index: index)
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        } else {
                            lockedRow(days: days, index: index)
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
                listAppeared = true
                let currentDays = store.currentDays
                if currentDays > lastSeenEarnedMilestone {
                    let justEarned = Milestone.allDays.last { $0 <= currentDays && $0 > lastSeenEarnedMilestone }
                    if let earned = justEarned {
                        newlyEarnedMilestone = earned
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

    private func earnedRow(days: Int, index: Int) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(StackTheme.ember.opacity(0.08))
                    Circle()
                        .stroke(StackTheme.ember, lineWidth: 1.5)
                    Text(Milestone.shortLabel(for: days))
                        .font(StackTypography.callout)
                        .foregroundStyle(StackTheme.ember)
                }
                .frame(width: 40, height: 40)
                .scaleEffect(newlyEarnedMilestone == days ? 1.12 : 1.0)
                .animation(
                    reduceMotion ? nil :
                        (newlyEarnedMilestone == days
                            ? .spring(duration: 0.3, bounce: 0.5).repeatCount(2, autoreverses: true)
                            : .default),
                    value: newlyEarnedMilestone
                )

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(Milestone.label(for: days) ?? "")
                            .font(StackTypography.body)
                            .foregroundStyle(.white)

                        if !store.receivedRelayDays.contains(days) {
                            Circle()
                                .fill(StackTheme.ember)
                                .frame(width: 5, height: 5)
                        }
                    }

                    if let info = store.earnedDate(for: days) {
                        Text("\(StackDateFormatter.string(from: info.date)) · Chapter \(info.chapter.chapterNumber)")
                            .font(StackTypography.caption)
                            .foregroundStyle(StackTheme.secondaryText)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(StackTheme.secondaryText)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            StackTheme.separator.frame(height: 0.5)
                .padding(.leading, 80)
        }
        .contentShape(Rectangle())
        .opacity(listAppeared ? 1.0 : 0.0)
        .offset(y: listAppeared ? 0 : 6)
        .animation(
            reduceMotion ? nil : StackAnimation.cardEntrance.delay(Double(index) * 0.05),
            value: listAppeared
        )
    }

    private func lockedRow(days: Int, index: Int) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Circle()
                    .stroke(StackTheme.ghost, lineWidth: 1.5)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(Milestone.label(for: days) ?? "")
                        .font(StackTypography.body)
                        .foregroundStyle(StackTheme.secondaryText)

                    let remaining = Milestone.daysUntil(from: store.currentDays, to: days)
                    Text("In \(remaining) days")
                        .font(StackTypography.caption)
                        .foregroundStyle(StackTheme.secondaryText)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .allowsHitTesting(false)

            StackTheme.separator.frame(height: 0.5)
                .padding(.leading, 80)
                .opacity(0.4)
        }
        .opacity(listAppeared ? 1.0 : 0.0)
        .offset(y: listAppeared ? 0 : 6)
        .animation(
            reduceMotion ? nil : StackAnimation.cardEntrance.delay(Double(index) * 0.05),
            value: listAppeared
        )
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}
