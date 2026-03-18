import SwiftUI

struct OnboardingContainerView: View {
    let store: StackStore
    @State private var currentPage: Int = 0
    @State private var selectedPath: OnboardingPath?
    @State private var selectedDate: Date = Date()
    @State private var showHistory: Bool = false
    @State private var previousChapters: [PreviousChapterEntry] = []
    @State private var historyCurrentStart: Date = Date()
    @State private var showAddChapter: Bool = false
    @State private var addChapterStart: Date = Date()
    @State private var addChapterEnd: Date = Date()

    enum OnboardingPath {
        case new
        case existing
    }

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Group {
                    switch currentPage {
                    case 0: screen1
                    case 1: screen2
                    case 2: screen3
                    case 3: screen4
                    case 4:
                        if selectedPath == .new {
                            screen5A
                        } else {
                            screen5B
                        }
                    default: EmptyView()
                    }
                }

                Spacer()

                if currentPage < 3 {
                    pageIndicator
                        .padding(.bottom, 48)
                }
            }
        }
        .gesture(
            currentPage < 3 ?
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 {
                        withAnimation(.smooth) { currentPage += 1 }
                    }
                }
            : nil
        )
    }

    private var screen1: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Wherever you are, you're not starting over.")
                .font(.system(size: 42, weight: .thin))
                .foregroundStyle(StackTheme.primaryText)

            Text("Whether this is Day 1 or Day 847 — everything counts.")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 24)

            Text("Nothing resets. Nothing disappears. It all stacks.")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 16)
        }
        .padding(.horizontal, 28)
    }

    private var screen2: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("No resets. Ever.")
                .font(.system(size: 42, weight: .thin))
                .foregroundStyle(StackTheme.primaryText)

            Text("Other apps count what you lose when you slip.")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 24)

            Text("STACK keeps everything. Every chapter stays.")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 16)

            VStack(alignment: .leading, spacing: 4) {
                Text("Chapter 1  ·  127 days  ·  Mar 2023 – Jul 2023")
                Text("Chapter 2  ·  currently at Day 847")
                StackTheme.separator.frame(height: 0.5).padding(.vertical, 4)
                Text("974 days stacked")
            }
            .font(.system(size: 13, weight: .light))
            .foregroundStyle(StackTheme.tertiaryText)
            .padding(.top, 32)
        }
        .padding(.horizontal, 28)
    }

    private var screen3: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Someone left you something.")
                .font(.system(size: 42, weight: .thin))
                .foregroundStyle(StackTheme.primaryText)

            Text("When you hit a milestone, a message arrives.")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 24)

            Text("From someone who stood exactly where you're standing.")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 16)

            Text("When you're ready, you write one forward.")
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 16)
        }
        .padding(.horizontal, 28)
    }

    private var screen4: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Where are you?")
                .font(.system(size: 42, weight: .thin))
                .foregroundStyle(StackTheme.primaryText)

            Spacer().frame(height: 48)

            Button {
                selectedPath = .new
                withAnimation(.smooth) { currentPage = 4 }
            } label: {
                Text("Starting today")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(StackTheme.primaryText)
                    .clipShape(.rect(cornerRadius: 12))
            }

            Button {
                selectedPath = .existing
                withAnimation(.smooth) { currentPage = 4 }
            } label: {
                Text("I'm already counting")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "1C1B19"))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 28)
    }

    private var screen5A: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("When did you last drink?")
                .font(.system(size: 34, weight: .thin))
                .foregroundStyle(StackTheme.primaryText)

            Text("Or tap below if today is Day 1.")
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 8)

            DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .padding(.top, 24)

            Button {
                store.createInitialChapter(startDate: selectedDate)
            } label: {
                let isToday = Calendar.current.isDateInToday(selectedDate)
                Text(isToday ? "This is Day 1" : "Start from \(Self.formatDate(selectedDate))")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(StackTheme.primaryText)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.top, 24)

            Text("STACK · No account. No sync. Your data stays on your device.")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(StackTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
        }
        .padding(.horizontal, 28)
    }

    private var screen5B: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Let's bring it all.")
                    .font(.system(size: 34, weight: .thin))
                    .foregroundStyle(StackTheme.primaryText)

                Text("CURRENT CHAPTER")
                    .font(.system(size: 11, weight: .light))
                    .tracking(1.5)
                    .foregroundStyle(StackTheme.tertiaryText)
                    .padding(.top, 24)

                DatePicker("Started on", selection: $historyCurrentStart, in: ...Date(), displayedComponents: .date)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)
                    .colorScheme(.dark)
                    .padding(.top, 8)

                Toggle(isOn: $showHistory) {
                    Text("I have previous chapters")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(StackTheme.secondaryText)
                }
                .tint(StackTheme.primaryText)
                .padding(.top, 24)

                if showHistory {
                    Text("PREVIOUS CHAPTERS")
                        .font(.system(size: 11, weight: .light))
                        .tracking(1.5)
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 24)

                    ForEach(previousChapters) { entry in
                        let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: entry.endDate).day ?? 0
                        Text("Chapter \(entry.number) · \(days) days · \(StackDateFormatter.string(from: entry.startDate)) – \(StackDateFormatter.string(from: entry.endDate))")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .padding(.top, 8)
                    }

                    Button {
                        showAddChapter = true
                    } label: {
                        Text("+ Add chapter")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(StackTheme.secondaryText)
                    }
                    .padding(.top, 12)
                }

                historyPreview
                    .padding(.top, 32)

                Button {
                    commitHistory()
                } label: {
                    Text("Start stacking")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(StackTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(StackTheme.primaryText)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.top, 24)
                .padding(.bottom, 48)
            }
            .padding(.horizontal, 28)
        }
        .sheet(isPresented: $showAddChapter) {
            addChapterSheet
        }
    }

    private var historyPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            let currentDays = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: historyCurrentStart), to: Calendar.current.startOfDay(for: Date())).day ?? 0
            let chapterNum = previousChapters.count + 1

            Text("Chapter \(chapterNum)  ·  currently Day \(currentDays)")
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(StackTheme.primaryText)

            ForEach(previousChapters.reversed()) { entry in
                let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: entry.endDate).day ?? 0
                Text("Chapter \(entry.number)  ·  \(days) days")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.tertiaryText)
            }

            StackTheme.separator.frame(height: 0.5).padding(.vertical, 4)

            let totalPrevious = previousChapters.reduce(0) {
                $0 + (Calendar.current.dateComponents([.day], from: $1.startDate, to: $1.endDate).day ?? 0)
            }
            Text("\(currentDays + totalPrevious) days stacked")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(StackTheme.secondaryText)
        }
    }

    private var addChapterSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                DatePicker("Start date", selection: $addChapterStart, in: ...Date(), displayedComponents: .date)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)
                DatePicker("End date", selection: $addChapterEnd, in: ...Date(), displayedComponents: .date)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .background(StackTheme.background)
            .navigationTitle("Add Chapter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddChapter = false }
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(StackTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let entry = PreviousChapterEntry(
                            number: previousChapters.count + 1,
                            startDate: addChapterStart,
                            endDate: addChapterEnd
                        )
                        previousChapters.append(entry)
                        showAddChapter = false
                    }
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(StackTheme.primaryText)
                }
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? StackTheme.primaryText : StackTheme.ghost)
                    .frame(width: 5, height: 5)
            }
        }
    }

    private func commitHistory() {
        var chapters: [Chapter] = []
        for entry in previousChapters {
            let chapter = Chapter(
                startDate: Calendar.current.startOfDay(for: entry.startDate),
                endDate: Calendar.current.startOfDay(for: entry.endDate),
                chapterNumber: entry.number
            )
            chapters.append(chapter)
        }
        let currentChapter = Chapter(
            startDate: Calendar.current.startOfDay(for: historyCurrentStart),
            chapterNumber: previousChapters.count + 1
        )
        chapters.append(currentChapter)
        store.importChapters(chapters)
    }

    static func formatDate(_ date: Date) -> String {
        StackDateFormatter.string(from: date)
    }
}

struct PreviousChapterEntry: Identifiable {
    let id: String = UUID().uuidString
    let number: Int
    let startDate: Date
    let endDate: Date
}
