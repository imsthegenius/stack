import SwiftUI

struct TodayView: View {
    let store: StackStore
    var switchToJourneyTab: (() -> Void)?
    @State private var pledgedToday: Bool = false
    @State private var showMilestoneMoment: Bool = false

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if let chapter = store.currentChapter {
                    Button {
                        switchToJourneyTab?()
                    } label: {
                        Text("CHAPTER \(chapter.chapterNumber)")
                            .font(.system(size: 11, weight: .light))
                            .tracking(1.5)
                            .foregroundStyle(StackTheme.tertiaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 28)
                            .padding(.top, 16)
                            .contentShape(Rectangle())
                    }
                }

                Spacer()

                counterBlock

                if store.chapters.count > 1 {
                    Text("\(store.totalDays) days total across \(store.chapters.count) chapters")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 20)
                }

                Spacer()
                Spacer().frame(height: 48)
            }
        }
        .onAppear {
            pledgedToday = store.hasPledgedToday
        }
        .onChange(of: store.hasPledgedToday) { _, newValue in
            pledgedToday = newValue
        }
    }

    private var counterBlock: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: pledgedToday ? 1.0 : 0.0)
                .stroke(Color(hex: "F4F2EE"), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 200, height: 200)
                .animation(.easeInOut(duration: 0.5), value: pledgedToday)

            VStack(spacing: 4) {
                Text("\(store.currentDays)")
                    .font(.system(size: 88, weight: .thin))
                    .foregroundStyle(store.isMilestoneDay ? StackTheme.milestoneWhite : StackTheme.primaryText)
                    .contentTransition(.numericText())

                Text("DAYS")
                    .font(.system(size: 13, weight: .light))
                    .tracking(2)
                    .foregroundStyle(StackTheme.secondaryText)

                if store.isMilestoneDay, let label = store.currentMilestoneLabel {
                    Button {
                        if pledgedToday {
                            showMilestoneMoment = true
                        }
                    } label: {
                        Text(label.uppercased())
                            .font(.system(size: 13, weight: .light))
                            .tracking(1.5)
                            .foregroundStyle(StackTheme.milestoneWhite)
                            .padding(.top, 4)
                    }
                    .disabled(!pledgedToday)
                }
            }
        }
        .contentShape(Circle())
        .onTapGesture {
            guard !pledgedToday else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                pledgedToday = true
            }
            store.pledgeToday()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            if store.isMilestoneDay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showMilestoneMoment = true
                }
            }
        }
    }
}
