import SwiftUI

struct JourneyView: View {
    let store: StackStore
    @State private var showNewChapterConfirm: Bool = false

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
                        .padding(.bottom, 12)

                    let chapters = store.sortedChapters
                    ForEach(Array(chapters.enumerated()), id: \.element.id) { index, chapter in
                        HStack(alignment: .top, spacing: 0) {
                            timelineColumn(isCurrentChapter: chapter.isCurrentChapter, isLast: index == chapters.count - 1)

                            Group {
                                if chapter.isCurrentChapter {
                                    currentChapterContent(chapter)
                                } else {
                                    pastChapterContent(chapter)
                                }
                            }
                        }
                    }

                    VStack(spacing: 4) {
                        Text("\(store.totalDays) days stacked")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(StackTheme.secondaryText)

                        if store.chapters.count > 1 {
                            Text("Across \(store.chapters.count) chapters")
                                .font(StackTypography.caption)
                                .foregroundStyle(StackTheme.tertiaryText)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(16)
                    .background(StackTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
                            .stroke(StackTheme.cardBorder, lineWidth: 1.0)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 32)

                    Button {
                        showNewChapterConfirm = true
                    } label: {
                        Text("Start new chapter")
                            .font(StackTypography.cta)
                            .foregroundStyle(StackTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(StackTheme.cardBackground)
                            .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
                            .overlay(
                                RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall)
                                    .stroke(StackTheme.cardBorder, lineWidth: 1.0)
                            )
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .padding(.horizontal, 20)
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

    private func timelineColumn(isCurrentChapter: Bool, isLast: Bool) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer().frame(height: 14)
            Circle()
                .fill(isCurrentChapter ? StackTheme.gold : StackTheme.ghost)
                .frame(width: 7, height: 7)
            if !isLast {
                Rectangle()
                    .fill(StackTheme.ghost)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 28)
    }

    private func currentChapterContent(_ chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CHAPTER \(chapter.chapterNumber)")
                .font(StackTypography.overline)
                .tracking(1.5)
                .foregroundStyle(StackTheme.secondaryText)

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
                .foregroundStyle(StackTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(StackTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
                .stroke(StackTheme.cardBorder, lineWidth: 1.0)
        )
        .padding(.trailing, 20)
        .padding(.vertical, 12)
    }

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
                    .foregroundStyle(StackTheme.tertiaryText)
            }

            let startFormatted = StackDateFormatter.string(from: chapter.startDate)
            let endFormatted = chapter.endDate.map { StackDateFormatter.string(from: $0) } ?? ""
            Text("\(startFormatted) – \(endFormatted)")
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(StackTheme.ghost.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
        .padding(.trailing, 20)
        .padding(.vertical, 8)
    }
}
