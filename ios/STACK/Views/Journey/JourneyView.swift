import SwiftUI

struct JourneyView: View {
    let store: StackStore
    @State private var showNewChapterConfirm: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Journey")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(StackTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    ForEach(store.sortedChapters) { chapter in
                        if chapter.isCurrentChapter {
                            currentChapterRow(chapter)
                        } else {
                            pastChapterRow(chapter)
                        }

                        if chapter.id != store.sortedChapters.last?.id {
                            StackTheme.separator
                                .frame(height: 0.5)
                                .padding(.horizontal, 28)
                        }
                    }

                    VStack(spacing: 4) {
                        Text("\(store.totalDays) days stacked")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(StackTheme.secondaryText)

                        if store.chapters.count > 1 {
                            Text("Across \(store.chapters.count) chapters")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(StackTheme.tertiaryText)
                        }
                    }
                    .padding(.top, 32)

                    Button {
                        showNewChapterConfirm = true
                    } label: {
                        Text("Start new chapter")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .padding(.vertical, 14)
                            .contentShape(Rectangle())
                    }
                    .padding(.top, 40)
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

    private func currentChapterRow(_ chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CHAPTER \(chapter.chapterNumber)")
                .font(.system(size: 12, weight: .regular))
                .tracking(1.5)
                .foregroundStyle(StackTheme.secondaryText)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(chapter.daysCount)")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(StackTheme.primaryText)

                Text("days")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(StackTheme.secondaryText)
            }

            Text("Since \(StackDateFormatter.string(from: chapter.startDate))")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(StackTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
    }

    private func pastChapterRow(_ chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CHAPTER \(chapter.chapterNumber)")
                .font(.system(size: 12, weight: .regular))
                .tracking(1.5)
                .foregroundStyle(StackTheme.secondaryText)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(chapter.daysCount)")
                    .font(.system(size: 28, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)

                Text("days")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(StackTheme.tertiaryText)
            }

            let startFormatted = StackDateFormatter.string(from: chapter.startDate)
            let endFormatted = chapter.endDate.map { StackDateFormatter.string(from: $0) } ?? ""
            Text("\(startFormatted) – \(endFormatted)")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(StackTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
    }
}
