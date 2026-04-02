import SwiftUI


struct OnboardingContainerView: View {
    let store: StackStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentPage: Int = 0
    @State private var selectedPath: OnboardingPath?
    @State private var selectedDate: Date = Date()
    @State private var showHistory: Bool = false
    @State private var previousChapters: [PreviousChapterEntry] = []
    @State private var historyCurrentStart: Date = Date()
    @State private var showAddChapter: Bool = false
    @State private var addChapterStart: Date = Date()
    @State private var addChapterEnd: Date = Date()
    @State private var showConfirmation: Bool = false
    @State private var confirmedDate: Date?
    @State private var showHistorySummary: Bool = false
    @State private var visibleElements: Int = 0
    enum OnboardingPath {
        case new
        case existing
    }

    // MARK: - Computed helpers for add-chapter validation

    private var addChapterDateRangeInvalid: Bool {
        addChapterEnd <= addChapterStart
    }

    private var addChapterOverlapsExisting: Bool {
        previousChapters.contains { entry in
            addChapterStart < entry.endDate && addChapterEnd > entry.startDate
        }
    }

    private var addChapterIsValid: Bool {
        !addChapterDateRangeInvalid && !addChapterOverlapsExisting
    }

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(minHeight: 60)

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
                .id(currentPage)
                .transition(.opacity)

                Spacer()
                Spacer()

                if currentPage < 3 {
                    pageIndicator
                        .padding(.bottom, 48)
                }
            }
            .task(id: currentPage) {
                guard !reduceMotion else {
                    visibleElements = 3
                    return
                }
                withAnimation(.easeOut(duration: 0.3)) { visibleElements = 1 }
                try? await Task.sleep(nanoseconds: 80_000_000)
                withAnimation(.easeOut(duration: 0.3)) { visibleElements = 2 }
                try? await Task.sleep(nanoseconds: 80_000_000)
                withAnimation(.easeOut(duration: 0.3)) { visibleElements = 3 }
            }
            .onChange(of: currentPage) { _, _ in
                if !reduceMotion { visibleElements = 0 }
            }
        }
        .overlay(alignment: .topLeading) {
            if currentPage >= 3 {
                Button {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) { currentPage -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(16)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Back")
                .padding(.top, 8)
            }
        }
        .overlay(alignment: .topTrailing) {
            if currentPage < 3 {
                Button {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) { currentPage = 3 }
                } label: {
                    Text("Skip")
                        .font(StackTypography.body)
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(16)
                        .contentShape(Rectangle())
                }
                .padding(.top, 8)
            }
        }
        .gesture(
            currentPage < 3 ?
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width < -30 {
                        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) { currentPage += 1 }
                    } else if value.translation.width > 30 && currentPage > 0 {
                        withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) { currentPage -= 1 }
                    }
                }
            : nil
        )
    }

    // MARK: - Screen 1

    private var screen1: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Every day counts.")
                .font(.system(size: 42, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .entranceAnimation(visible: visibleElements >= 1)

            Text("Whether this is Day 1 or Day 847, nothing disappears.")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .padding(.top, 24)
                .entranceAnimation(visible: visibleElements >= 2)

            Text("Nothing resets. It all stacks.")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .padding(.top, 16)
                .entranceAnimation(visible: visibleElements >= 2)

            ZStack {
                Circle()
                    .stroke(StackTheme.primaryText, lineWidth: 1.5)
                    .frame(width: 80, height: 80)
                Text("14")
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(StackTheme.primaryText)
            }
            .padding(.top, 48)
            .entranceAnimation(visible: visibleElements >= 3)

            Spacer()

            Button {
                store.hasCompletedOnboarding = true
                store.save()
            } label: {
                Text("I already have an account")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(StackTheme.cardBackground)
                    .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
                    .overlay(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall).stroke(StackTheme.cardBorder, lineWidth: 1.0))
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.bottom, 24)
            .entranceAnimation(visible: visibleElements >= 3)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Screen 2

    private var screen2: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("No resets. Ever.")
                .font(.system(size: 42, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .entranceAnimation(visible: visibleElements >= 1)

            Text("Other counters start you back at zero.")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .padding(.top, 24)
                .entranceAnimation(visible: visibleElements >= 2)

            Text("STACK keeps everything. Every chapter stays.")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .padding(.top, 16)
                .entranceAnimation(visible: visibleElements >= 2)

            StackCard(padding: 16, radius: StackTheme.cardRadiusSmall) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Chapter 1  ·  127 days  ·  Mar–Jul 2023")
                        .font(StackTypography.footnote)
                        .foregroundStyle(StackTheme.tertiaryText)
                    Text("Chapter 2  ·  currently at Day 847")
                        .font(StackTypography.footnote)
                        .foregroundStyle(StackTheme.secondaryText)
                    StackTheme.separator.frame(height: 0.5).padding(.vertical, 2)
                    Text("974 days stacked")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(StackTheme.secondaryText)
                }
            }
            .padding(.top, 32)
            .entranceAnimation(visible: visibleElements >= 3)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Screen 3

    private var screen3: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Messages at milestones.")
                .font(.system(size: 42, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .entranceAnimation(visible: visibleElements >= 1)

            Text("At certain days, a short anonymous message appears.")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .padding(.top, 24)
                .entranceAnimation(visible: visibleElements >= 2)

            Text("Written by someone who reached that number before you.")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .padding(.top, 16)
                .entranceAnimation(visible: visibleElements >= 2)

            Text("When you're ready, you leave one for the next person.")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .padding(.top, 16)
                .entranceAnimation(visible: visibleElements >= 2)

            StackCard(padding: 20, radius: StackTheme.cardRadiusSmall) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The first month is a wall. The second is a door.")
                        .font(Font.custom("Georgia", size: 17))
                        .foregroundStyle(StackTheme.primaryText)
                        .lineSpacing(5)
                    Text("— from day 47")
                        .font(StackTypography.caption)
                        .foregroundStyle(StackTheme.tertiaryText)
                }
            }
            .padding(.top, 24)
            .entranceAnimation(visible: visibleElements >= 3)

            Text("Your first week of messages is free. After that, one payment unlocks the relay forever.")
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.tertiaryText)
                .padding(.top, 16)
                .entranceAnimation(visible: visibleElements >= 3)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Screen 4

    private var screen4: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Where are you?")
                .font(.system(size: 42, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)
                .entranceAnimation(visible: visibleElements >= 1)

            Spacer().frame(height: 48)

            Button {
                selectedPath = .new
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) { currentPage = 4 }
            } label: {
                Text("Starting today")
                    .font(StackTypography.cta)
                    .foregroundStyle(StackTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(StackTheme.primaryText)
                    .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
            }
            .buttonStyle(PressScaleButtonStyle())
            .entranceAnimation(visible: visibleElements >= 2)

            Button {
                selectedPath = .existing
                withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) { currentPage = 4 }
            } label: {
                Text("I'm already counting")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(StackTheme.cardBackground)
                    .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
                    .overlay(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall).stroke(StackTheme.cardBorder, lineWidth: 1.0))
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.top, 16)
            .entranceAnimation(visible: visibleElements >= 3)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Screen 5A (new chapter)

    private var screen5A: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showConfirmation, let date = confirmedDate {
                let dayCount = max(1, (Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: date), to: Calendar.current.startOfDay(for: Date())).day ?? 0) + 1)

                Text("Starting from \(Self.formatDate(date)).")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(StackTheme.primaryText)

                Text("Day \(dayCount).")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(StackTheme.primaryText)
                    .padding(.top, 8)

                Spacer()

                Button {
                    let isToday = Calendar.current.isDateInToday(date)
                    let startDate = isToday
                        ? Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: date))!
                        : date
                    store.createInitialChapter(startDate: startDate)
                } label: {
                    Text("Let's go")
                        .font(StackTypography.cta)
                        .foregroundStyle(StackTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(StackTheme.primaryText)
                        .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) { showConfirmation = false }
                } label: {
                    Text("Change date")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            } else {
                Text("When did your current chapter begin?")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(StackTheme.primaryText)
                    .entranceAnimation(visible: visibleElements >= 1)

                Text("Or tap below if today is Day 1.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(StackTheme.primaryText)
                    .padding(.top, 8)
                    .entranceAnimation(visible: visibleElements >= 1)

                DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(StackTheme.primaryText)
                    .frame(maxHeight: 200)
                    .padding(.top, 16)
                    .entranceAnimation(visible: visibleElements >= 2)

                Button {
                    confirmedDate = selectedDate
                    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) { showConfirmation = true }
                } label: {
                    let isToday = Calendar.current.isDateInToday(selectedDate)
                    Text(isToday ? "This is Day 1" : "Start from \(Self.formatDate(selectedDate))")
                        .font(StackTypography.cta)
                        .foregroundStyle(StackTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(StackTheme.primaryText)
                        .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
                }
                .buttonStyle(PressScaleButtonStyle())
                .padding(.top, 24)
                .entranceAnimation(visible: visibleElements >= 3)

                Text("Sign in after setup to back up your progress.")
                    .font(StackTypography.caption)
                    .foregroundStyle(StackTheme.tertiaryText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .entranceAnimation(visible: visibleElements >= 3)
            }
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Screen 5B (existing counter)

    private var currentStartOverlapMessage: String? {
        guard !previousChapters.isEmpty else { return nil }
        let currentStart = Calendar.current.startOfDay(for: historyCurrentStart)
        for entry in previousChapters {
            if currentStart < Calendar.current.startOfDay(for: entry.endDate) {
                let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: entry.endDate).day ?? 0
                return "Overlaps with Chapter \(entry.number) (\(StackDateFormatter.string(from: entry.startDate)) – \(StackDateFormatter.string(from: entry.endDate)), \(days) days)"
            }
        }
        return nil
    }

    private var screen5B: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Let's bring it all.")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(StackTheme.primaryText)
                    .entranceAnimation(visible: visibleElements >= 1)

                Text("CURRENT CHAPTER")
                    .font(StackTypography.overline)
                    .tracking(1.5)
                    .foregroundStyle(StackTheme.tertiaryText)
                    .padding(.top, 24)
                    .entranceAnimation(visible: visibleElements >= 2)

                DatePicker("Started on", selection: $historyCurrentStart, in: ...Date(), displayedComponents: .date)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StackTheme.secondaryText)
                    .colorScheme(.dark)
                    .tint(StackTheme.primaryText)
                    .padding(.top, 8)
                    .entranceAnimation(visible: visibleElements >= 2)
                    .onChange(of: historyCurrentStart) { _, newValue in
                        if newValue > Date() {
                            historyCurrentStart = Date()
                        }
                    }

                if let overlap = currentStartOverlapMessage {
                    Text(overlap)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 4)
                }

                Toggle(isOn: $showHistory) {
                    Text("I have previous chapters")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(StackTheme.secondaryText)
                }
                .tint(StackTheme.primaryText)
                .padding(.top, 24)
                .entranceAnimation(visible: visibleElements >= 2)

                if showHistory {
                    Text("PREVIOUS CHAPTERS")
                        .font(StackTypography.overline)
                        .tracking(1.5)
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 24)

                    List {
                        ForEach(previousChapters) { entry in
                            let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: entry.endDate).day ?? 0
                            Text("Chapter \(entry.number) · \(days) days · \(StackDateFormatter.string(from: entry.startDate)) – \(StackDateFormatter.string(from: entry.endDate))")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(StackTheme.tertiaryText)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        }
                        .onDelete { offsets in
                            previousChapters.remove(atOffsets: offsets)
                            renumberChapters()
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: CGFloat(previousChapters.count) * 36)
                    .environment(\.editMode, .constant(.active))

                    Button {
                        showAddChapter = true
                    } label: {
                        Text("+ Add chapter")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(StackTheme.secondaryText)
                    }
                    .padding(.top, 12)
                }

                StackCard(padding: 16, radius: StackTheme.cardRadiusSmall) {
                    historyPreview
                }
                .padding(.top, 32)
                .entranceAnimation(visible: visibleElements >= 2)

                Button {
                    showHistorySummary = true
                } label: {
                    Text("Start stacking")
                        .font(StackTypography.cta)
                        .foregroundStyle(StackTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(currentStartOverlapMessage == nil ? StackTheme.primaryText : StackTheme.ghost)
                        .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(currentStartOverlapMessage != nil)
                .padding(.top, 24)
                .padding(.bottom, 48)
                .entranceAnimation(visible: visibleElements >= 3)
            }
            .padding(.horizontal, 28)
        }
        .sheet(isPresented: $showAddChapter) {
            addChapterSheet
        }
        .alert("Ready?", isPresented: $showHistorySummary) {
            Button("Let's go") {
                commitHistory()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            let currentDays = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: historyCurrentStart), to: Calendar.current.startOfDay(for: Date())).day ?? 0
            let totalPrevious = previousChapters.reduce(0) {
                $0 + (Calendar.current.dateComponents([.day], from: $1.startDate, to: $1.endDate).day ?? 0)
            }
            let chapterCount = previousChapters.count + 1
            Text("\(chapterCount) chapters, \(currentDays + totalPrevious) total days.")
        }
    }

    private var historyPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            let currentDays = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: historyCurrentStart), to: Calendar.current.startOfDay(for: Date())).day ?? 0
            let chapterNum = previousChapters.count + 1

            Text("Chapter \(chapterNum)  ·  currently Day \(currentDays)")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(StackTheme.primaryText)

            ForEach(previousChapters.reversed()) { entry in
                let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: entry.endDate).day ?? 0
                Text("Chapter \(entry.number)  ·  \(days) days")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StackTheme.tertiaryText)
            }

            StackTheme.separator.frame(height: 0.5).padding(.vertical, 4)

            let totalPrevious = previousChapters.reduce(0) {
                $0 + (Calendar.current.dateComponents([.day], from: $1.startDate, to: $1.endDate).day ?? 0)
            }
            Text("\(currentDays + totalPrevious) days stacked")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(StackTheme.secondaryText)
        }
    }

    private var addChapterSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                DatePicker("Start date", selection: $addChapterStart, in: ...Date(), displayedComponents: .date)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StackTheme.secondaryText)
                    .colorScheme(.dark)
                    .tint(StackTheme.primaryText)
                DatePicker("End date", selection: $addChapterEnd, in: ...Date(), displayedComponents: .date)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StackTheme.secondaryText)
                    .colorScheme(.dark)
                    .tint(StackTheme.primaryText)

                if addChapterDateRangeInvalid {
                    Text("End date must be after start date.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if addChapterOverlapsExisting {
                    if let overlapping = previousChapters.first(where: { entry in
                        addChapterStart < entry.endDate && addChapterEnd > entry.startDate
                    }) {
                        Text("Overlaps with Chapter \(overlapping.number) (\(StackDateFormatter.string(from: overlapping.startDate)) – \(StackDateFormatter.string(from: overlapping.endDate)))")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

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
                        .font(.system(size: 16, weight: .regular))
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
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(addChapterIsValid ? StackTheme.primaryText : StackTheme.tertiaryText)
                    .disabled(!addChapterIsValid)
                }
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                let isActive = index == currentPage
                Circle()
                    .fill(isActive ? StackTheme.primaryText : StackTheme.ghost)
                    .frame(
                        width: isActive ? 6 : 5,
                        height: isActive ? 6 : 5
                    )
                    .animation(
                        reduceMotion ? .none : .spring(duration: 0.25, bounce: 0.3),
                        value: currentPage
                    )
            }
        }
    }

    private func renumberChapters() {
        previousChapters = previousChapters.enumerated().map { index, entry in
            PreviousChapterEntry(number: index + 1, startDate: entry.startDate, endDate: entry.endDate)
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
