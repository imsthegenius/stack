import SwiftUI

struct JourneyView: View {
    let store: StackStore
    @State private var showNewChapterConfirm: Bool = false
    @State private var visibleRows: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Journey")
                        .font(StackTypography.title)
                        .foregroundStyle(StackTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                    let chapters = store.sortedChapters
                    ForEach(Array(chapters.enumerated()), id: \.element.id) { index, chapter in
                        HStack(alignment: .top, spacing: 0) {
                            timelineColumn(
                                isCurrentChapter: chapter.isCurrentChapter,
                                isLast: index == chapters.count - 1
                            )

                            Group {
                                if chapter.isCurrentChapter {
                                    currentChapterContent(chapter)
                                } else {
                                    pastChapterContent(chapter)
                                }
                            }
                        }
                        .entranceAnimation(visible: index < visibleRows)
                        .animation(
                            StackAnimation.cardEntrance.delay(Double(index) * StackAnimation.stagger),
                            value: visibleRows
                        )
                    }
                    .onAppear {
                        withAnimation {
                            visibleRows = chapters.count
                        }
                    }

                    // Summary — no card, just text on the void
                    VStack(spacing: 4) {
                        Text("\(store.totalDays) days stacked")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(StackTheme.primaryText)

                        if store.chapters.count > 1 {
                            Text("Across \(store.chapters.count) chapters")
                                .font(StackTypography.caption)
                                .foregroundStyle(StackTheme.secondaryText)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 32)

                    Button {
                        showNewChapterConfirm = true
                    } label: {
                        Text("Start new chapter")
                    }
                    .buttonStyle(SurfaceButtonStyle())
                    .padding(.horizontal, 28)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
                .padding(.top, 8)
            }
            .background(StackTheme.background)
            .navigationTitle("")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .confirmationDialog(
                "Start Chapter \(nextChapterNumber)?",
                isPresented: $showNewChapterConfirm,
                titleVisibility: .visible
            ) {
                Button("Start Chapter \(nextChapterNumber)") {
                    store.startNewChapter()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your \(store.currentDays) days in Chapter \(store.currentChapter?.chapterNumber ?? 1) are kept forever. A new chapter begins today.")
            }
        }
    }

    private var nextChapterNumber: Int {
        (store.currentChapter?.chapterNumber ?? 0) + 1
    }

    // MARK: - Timeline

    private func timelineColumn(isCurrentChapter: Bool, isLast: Bool) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer().frame(height: 14)
            Circle()
                .fill(isCurrentChapter ? StackTheme.ember : StackTheme.ghost)
                .frame(width: isCurrentChapter ? 8 : 6, height: isCurrentChapter ? 8 : 6)
            if !isLast {
                Rectangle()
                    .fill(StackTheme.ghost)
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 28)
    }

    // MARK: - Current Chapter (ember-accented)

    private func currentChapterContent(_ chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CHAPTER \(chapter.chapterNumber)")
                .font(StackTypography.overline)
                .tracking(1.5)
                .foregroundStyle(StackTheme.ember)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(chapter.daysCount)")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundStyle(StackTheme.primaryText)

                Text("days")
                    .font(StackTypography.footnote)
                    .foregroundStyle(StackTheme.secondaryText)
            }

            Text("Since \(StackDateFormatter.string(from: chapter.startDate))")
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.trailing, 28)
    }

    // MARK: - Past Chapter (muted)

    private func pastChapterContent(_ chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CHAPTER \(chapter.chapterNumber)")
                .font(StackTypography.overline)
                .tracking(1.5)
                .foregroundStyle(StackTheme.secondaryText)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(chapter.daysCount)")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(StackTheme.secondaryText)

                Text("days")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(StackTheme.secondaryText)
            }

            let startFormatted = StackDateFormatter.string(from: chapter.startDate)
            let endFormatted = chapter.endDate.map { StackDateFormatter.string(from: $0) } ?? ""
            Text("\(startFormatted) – \(endFormatted)")
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.trailing, 28)
    }
}
