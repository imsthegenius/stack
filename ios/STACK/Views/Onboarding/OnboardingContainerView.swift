import SwiftUI

struct OnboardingContainerView: View {
    let store: StackStore

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentPage: Int = 0
    @State private var selectedPath: OnboardingPath = .new
    @State private var selectedDate: Date = Date()
    @State private var showHistory: Bool = false
    @State private var previousChapters: [PreviousChapterEntry] = []
    @State private var historyCurrentStart: Date = Date()
    @State private var showAddChapter: Bool = false
    @State private var addChapterStart: Date = Date()
    @State private var addChapterEnd: Date = Date()
    @State private var showHistorySummary: Bool = false
    @State private var visibleElements: Int = 0

    enum OnboardingPath: CaseIterable {
        case new
        case existing

        var title: String {
            switch self {
            case .new:
                return "Starting today"
            case .existing:
                return "Already counting"
            }
        }

        var detail: String {
            switch self {
            case .new:
                return "Set the first day of this chapter."
            case .existing:
                return "Bring over your current and past chapters."
            }
        }
    }

    private var pageCount: Int { 4 }

    private var selectableDateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let earliest = Calendar.current.date(byAdding: .year, value: -30, to: today) ?? today
        return earliest...today
    }

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

    private var currentStartOverlapMessage: String? {
        guard !previousChapters.isEmpty else { return nil }

        let currentStart = Calendar.current.startOfDay(for: historyCurrentStart)
        for entry in previousChapters {
            if currentStart < Calendar.current.startOfDay(for: entry.endDate) {
                let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: entry.endDate).day ?? 0
                return "Overlaps with Chapter \(entry.number) (\(Self.formatDate(entry.startDate)) to \(Self.formatDate(entry.endDate)), \(days) days)"
            }
        }
        return nil
    }

    private var newPathDayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let selected = clampedSelectableDate(selectedDate)
        return max(1, (Calendar.current.dateComponents([.day], from: selected, to: today).day ?? 0) + 1)
    }

    private var newPathSummary: String {
        let selected = clampedSelectableDate(selectedDate)
        if Calendar.current.isDateInToday(selected) {
            return "Today becomes Day 1. Your first chapter starts now."
        }
        return "Starting on \(Self.formatDate(selected)) makes today Day \(newPathDayCount)."
    }

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                pageContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(currentPage)
                    .transition(.opacity)

                pageIndicator
                    .padding(.bottom, 32)
            }
        }
        .overlay(alignment: .topLeading) {
            if currentPage > 0 {
                Button {
                    goToPreviousPage()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(StackTypography.body)
                        .foregroundStyle(StackTheme.secondaryText)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Back")
                .padding(.top, 8)
                .padding(.leading, 8)
            }
        }
        .overlay(alignment: .topTrailing) {
            if currentPage < pageCount - 1 {
                Button {
                    goToPage(pageCount - 1)
                } label: {
                    Text("Skip")
                        .font(StackTypography.callout)
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
            }
        }
        .sheet(isPresented: $showAddChapter) {
            addChapterSheet
        }
        .alert("Ready?", isPresented: $showHistorySummary) {
            Button("Start stacking") {
                commitHistory()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            let currentDays = Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: historyCurrentStart),
                to: Calendar.current.startOfDay(for: Date())
            ).day ?? 0
            let totalPrevious = previousChapters.reduce(0) {
                $0 + (Calendar.current.dateComponents([.day], from: $1.startDate, to: $1.endDate).day ?? 0)
            }
            let chapterCount = previousChapters.count + 1
            Text("\(chapterCount) chapters, \(currentDays + totalPrevious) total days.")
        }
        .task(id: currentPage) {
            await animateCurrentPage()
        }
        .onChange(of: currentPage) { _, _ in
            if !reduceMotion {
                visibleElements = 0
            }
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        switch currentPage {
        case 0:
            marketingPage(
                title: "Every day counts.",
                body: "Whether this is Day 1 or Day 847, nothing disappears.",
                detail: "No resets. No lost history. It all stacks.",
                primaryTitle: "Continue",
                secondaryTitle: "I already have an account",
                visual: counterPreview,
                primaryAction: goToNextPage,
                secondaryAction: completeOnboarding
            )
        case 1:
            marketingPage(
                title: "No resets. Ever.",
                body: "Every chapter stays visible, even when life changes shape.",
                detail: "You keep the full timeline instead of pretending the earlier days never happened.",
                primaryTitle: "Continue",
                secondaryTitle: nil,
                visual: chapterPreview,
                primaryAction: goToNextPage,
                secondaryAction: nil
            )
        case 2:
            marketingPage(
                title: "Messages at milestones.",
                body: "At key days, a short anonymous note appears from someone who reached that number first.",
                detail: "When your time comes, you leave one forward.",
                primaryTitle: "Set up my chapter",
                secondaryTitle: nil,
                visual: relayPreview,
                primaryAction: goToNextPage,
                secondaryAction: nil
            )
        default:
            setupPage
        }
    }

    private func marketingPage<Visual: View>(
        title: String,
        body: String,
        detail: String,
        primaryTitle: String,
        secondaryTitle: String?,
        visual: Visual,
        primaryAction: @escaping () -> Void,
        secondaryAction: (() -> Void)?
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 76)

            Text(title)
                .font(StackTypography.display)
                .foregroundStyle(StackTheme.primaryText)
                .entranceAnimation(visible: visibleElements >= 1, offset: 18)

            Text(body)
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.primaryText)
                .padding(.top, 20)
                .entranceAnimation(visible: visibleElements >= 2, offset: 18)

            Text(detail)
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 10)
                .entranceAnimation(visible: visibleElements >= 2, offset: 18)

            visual
                .padding(.top, 40)
                .frame(maxWidth: .infinity)
                .entranceAnimation(visible: visibleElements >= 3, offset: 22)

            Spacer(minLength: 32)

            VStack(spacing: 12) {
                Button(action: primaryAction) {
                    Text(primaryTitle)
                }
                .buttonStyle(PrimaryCTAButtonStyle())

                if let secondaryTitle, let secondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryTitle)
                    }
                    .buttonStyle(SurfaceButtonStyle())
                }
            }
            .entranceAnimation(visible: visibleElements >= 4, offset: 18)
        }
        .padding(.horizontal, StackSpacing.horizontalPadding)
    }

    private var counterPreview: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(StackTheme.ghost, lineWidth: 2)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: 0.78)
                    .stroke(
                        StackTheme.ember,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)

                VStack(spacing: 2) {
                    Text("14")
                        .font(StackTypography.heroCounter)
                        .minimumScaleFactor(0.45)
                        .lineLimit(1)
                        .frame(width: 84)
                        .foregroundStyle(StackTheme.primaryText)
                    Text("DAYS")
                        .font(StackTypography.overline)
                        .tracking(1.5)
                        .foregroundStyle(StackTheme.secondaryText)
                }
            }

            Text("One tap fills the ring for today.")
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.secondaryText)
        }
    }

    private var chapterPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            previewChapterRow(
                title: "Chapter 2",
                detail: "Current chapter · Day 847",
                highlight: true
            )

            StackTheme.separator
                .frame(height: 1)
                .padding(.vertical, 14)

            previewChapterRow(
                title: "Chapter 1",
                detail: "127 days · Mar 2023 to Jul 2023",
                highlight: false
            )

            StackTheme.separator
                .frame(height: 1)
                .padding(.vertical, 14)

            Text("974 days stacked")
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func previewChapterRow(title: String, detail: String, highlight: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(highlight ? StackTheme.ember : StackTheme.ghost)
                .frame(width: highlight ? 10 : 8, height: highlight ? 10 : 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(StackTypography.callout)
                    .foregroundStyle(highlight ? StackTheme.primaryText : StackTheme.secondaryText)

                Text(detail)
                    .font(StackTypography.caption)
                    .foregroundStyle(StackTheme.secondaryText)
            }
        }
    }

    private var relayPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            RelayCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("The first month is a wall. The second is a door.")
                        .font(StackTypography.relay)
                        .foregroundStyle(StackTheme.primaryText)
                        .lineSpacing(5)

                    Text("From day 47")
                        .font(StackTypography.caption)
                        .foregroundStyle(StackTheme.secondaryText)
                }
            }

            Text("The relay is the only card in the flow.")
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.secondaryText)
        }
    }

    private var setupPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 76)

                Text("Where are you?")
                    .font(StackTypography.display)
                    .foregroundStyle(StackTheme.primaryText)
                    .entranceAnimation(visible: visibleElements >= 1, offset: 18)

                Text("Pick the start of this chapter. If you have older chapters, add them below so none of that time disappears.")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.primaryText)
                    .padding(.top, 20)
                    .entranceAnimation(visible: visibleElements >= 2, offset: 18)

                HStack(spacing: 12) {
                    ForEach(OnboardingPath.allCases, id: \.title) { path in
                        Button {
                            selectedPath = path
                            if path == .new {
                                showHistory = false
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(path.title)
                                Text(path.detail)
                                    .font(StackTypography.caption)
                                    .foregroundStyle(selectedPath == path ? StackTheme.background.opacity(0.7) : StackTheme.secondaryText)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(selectedPath == path ? AnyButtonStyle(PrimaryCTAButtonStyle()) : AnyButtonStyle(SurfaceButtonStyle()))
                    }
                }
                .padding(.top, 28)
                .entranceAnimation(visible: visibleElements >= 3, offset: 18)

                Group {
                    if selectedPath == .new {
                        newChapterSetup
                    } else {
                        existingChapterSetup
                    }
                }
                .padding(.top, 28)
                .entranceAnimation(visible: visibleElements >= 4, offset: 22)
            }
            .padding(.horizontal, StackSpacing.horizontalPadding)
            .padding(.bottom, 40)
        }
    }

    private var newChapterSetup: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Current chapter")

            StackDatePicker(selection: $selectedDate, range: selectableDateRange)
                .padding(.top, 14)

            Text(newPathSummary)
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 18)

            Button {
                let selected = clampedSelectableDate(selectedDate)
                let startOfDay = Calendar.current.startOfDay(for: selected)
                let startDate = Calendar.current.isDateInToday(selected)
                    ? Calendar.current.date(byAdding: .day, value: -1, to: startOfDay) ?? startOfDay
                    : startOfDay
                store.createInitialChapter(startDate: startDate)
            } label: {
                let selected = clampedSelectableDate(selectedDate)
                Text(Calendar.current.isDateInToday(selected) ? "Start at Day 1" : "Start from \(Self.formatDate(selected))")
            }
            .buttonStyle(PrimaryCTAButtonStyle())
            .padding(.top, 24)

            Text("You will sign in after setup so the timeline can sync and survive reinstalls.")
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 14)
        }
    }

    private var existingChapterSetup: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Current chapter")

            StackDatePicker(selection: $historyCurrentStart, range: selectableDateRange)
                .padding(.top, 14)
                .onChange(of: historyCurrentStart) { _, newValue in
                    let clamped = clampedSelectableDate(newValue)
                    if clamped != newValue {
                        historyCurrentStart = clamped
                    }
                }

            if let overlap = currentStartOverlapMessage {
                Text(overlap)
                    .font(StackTypography.caption)
                    .foregroundStyle(StackTheme.secondaryText)
                    .padding(.top, 12)
            }

            Toggle(isOn: $showHistory) {
                Text("I have previous chapters")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.primaryText)
            }
            .tint(StackTheme.ember)
            .padding(.top, 24)

            if showHistory {
                sectionHeader("Previous chapters")
                    .padding(.top, 28)

                if previousChapters.isEmpty {
                    Text("Add every closed chapter in order. The current chapter stays open.")
                        .font(StackTypography.caption)
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(.top, 10)
                } else {
                    previousChapterList
                        .padding(.top, 14)
                }

                Button {
                    let defaultStart = Calendar.current.date(byAdding: .day, value: -7, to: historyCurrentStart) ?? historyCurrentStart
                    addChapterStart = min(defaultStart, historyCurrentStart)
                    addChapterEnd = historyCurrentStart
                    showAddChapter = true
                } label: {
                    Text("Add chapter")
                }
                .buttonStyle(SurfaceButtonStyle())
                .padding(.top, 16)
            }

            historyPreview
                .padding(.top, 28)

            Button {
                showHistorySummary = true
            } label: {
                Text("Start stacking")
            }
            .buttonStyle(PrimaryCTAButtonStyle())
            .disabled(currentStartOverlapMessage != nil)
            .opacity(currentStartOverlapMessage == nil ? 1 : 0.45)
            .padding(.top, 24)
        }
    }

    private var previousChapterList: some View {
        VStack(spacing: 0) {
            ForEach(previousChapters) { entry in
                let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: entry.endDate).day ?? 0

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chapter \(entry.number)")
                            .font(StackTypography.callout)
                            .foregroundStyle(StackTheme.primaryText)

                        Text("\(days) days · \(Self.formatDate(entry.startDate)) to \(Self.formatDate(entry.endDate))")
                            .font(StackTypography.caption)
                            .foregroundStyle(StackTheme.secondaryText)
                    }

                    Spacer()

                    Button {
                        previousChapters.removeAll { $0.id == entry.id }
                        renumberChapters()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(StackTypography.callout)
                            .foregroundStyle(StackTheme.secondaryText)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Remove Chapter \(entry.number)")
                }
                .padding(.vertical, 12)

                if entry.id != previousChapters.last?.id {
                    StackTheme.separator.frame(height: 1)
                }
            }
        }
    }

    private var historyPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Preview")

            VStack(alignment: .leading, spacing: 10) {
                let currentDays = Calendar.current.dateComponents(
                    [.day],
                    from: Calendar.current.startOfDay(for: historyCurrentStart),
                    to: Calendar.current.startOfDay(for: Date())
                ).day ?? 0
                let chapterNum = previousChapters.count + 1

                Text("Chapter \(chapterNum) · currently Day \(currentDays)")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.primaryText)

                ForEach(previousChapters.reversed()) { entry in
                    let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: entry.endDate).day ?? 0
                    Text("Chapter \(entry.number) · \(days) days")
                        .font(StackTypography.caption)
                        .foregroundStyle(StackTheme.secondaryText)
                }

                StackTheme.separator
                    .frame(height: 1)
                    .padding(.vertical, 6)

                let totalPrevious = previousChapters.reduce(0) {
                    $0 + (Calendar.current.dateComponents([.day], from: $1.startDate, to: $1.endDate).day ?? 0)
                }
                Text("\(currentDays + totalPrevious) days stacked")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.primaryText)
            }
            .padding(.top, 14)
        }
    }

    private var addChapterSheet: some View {
        NavigationStack {
            ZStack {
                StackTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Previous chapter")
                            .font(StackTypography.title)
                            .foregroundStyle(StackTheme.primaryText)

                        sectionHeader("Start date")
                            .padding(.top, 28)

                        StackDatePicker(selection: $addChapterStart, range: selectableDateRange)
                            .padding(.top, 14)

                        sectionHeader("End date")
                            .padding(.top, 28)

                        StackDatePicker(selection: $addChapterEnd, range: selectableDateRange)
                            .padding(.top, 14)

                        if addChapterDateRangeInvalid {
                            Text("End date must be after the start date.")
                                .font(StackTypography.caption)
                                .foregroundStyle(StackTheme.secondaryText)
                                .padding(.top, 14)
                        } else if addChapterOverlapsExisting,
                                  let overlapping = previousChapters.first(where: { entry in
                                      addChapterStart < entry.endDate && addChapterEnd > entry.startDate
                                  }) {
                            Text("Overlaps with Chapter \(overlapping.number) (\(Self.formatDate(overlapping.startDate)) to \(Self.formatDate(overlapping.endDate))).")
                                .font(StackTypography.caption)
                                .foregroundStyle(StackTheme.secondaryText)
                                .padding(.top, 14)
                        }
                    }
                    .padding(.horizontal, StackSpacing.horizontalPadding)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddChapter = false
                    }
                    .foregroundStyle(StackTheme.secondaryText)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let startDate = clampedSelectableDate(addChapterStart)
                        let endDate = clampedSelectableDate(addChapterEnd)
                        let entry = PreviousChapterEntry(
                            number: previousChapters.count + 1,
                            startDate: startDate,
                            endDate: endDate
                        )
                        previousChapters.append(entry)
                        renumberChapters()
                        showAddChapter = false
                    }
                    .foregroundStyle(addChapterIsValid ? StackTheme.primaryText : StackTheme.secondaryText)
                    .disabled(!addChapterIsValid)
                }
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                let isActive = index == currentPage
                Capsule()
                    .fill(isActive ? StackTheme.ember : StackTheme.ghost)
                    .frame(width: isActive ? 22 : 6, height: 6)
                    .animation(reduceMotion ? .none : StackAnimation.entrance, value: currentPage)
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(StackTypography.overline)
            .tracking(1.5)
            .foregroundStyle(StackTheme.secondaryText)
    }

    private func animateCurrentPage() async {
        guard !reduceMotion else {
            visibleElements = 4
            return
        }

        visibleElements = 0
        for step in 1...4 {
            withAnimation(StackAnimation.entrance) {
                visibleElements = step
            }
            try? await Task.sleep(nanoseconds: 80_000_000)
        }
    }

    private func goToPage(_ page: Int) {
        let target = max(0, min(page, pageCount - 1))
        withAnimation(reduceMotion ? .none : StackAnimation.entrance) {
            currentPage = target
        }
    }

    private func goToNextPage() {
        goToPage(currentPage + 1)
    }

    private func goToPreviousPage() {
        goToPage(currentPage - 1)
    }

    private func completeOnboarding() {
        store.hasCompletedOnboarding = true
        store.save()
    }

    private func renumberChapters() {
        previousChapters = previousChapters.enumerated().map { index, entry in
            PreviousChapterEntry(number: index + 1, startDate: entry.startDate, endDate: entry.endDate)
        }
    }

    private func commitHistory() {
        var chapters: [Chapter] = []

        let sanitizedPreviousChapters = previousChapters
            .map { entry in
                (
                    startDate: clampedSelectableDate(entry.startDate),
                    endDate: clampedSelectableDate(entry.endDate)
                )
            }
            .filter { $0.endDate > $0.startDate }

        for (index, entry) in sanitizedPreviousChapters.enumerated() {
            let chapter = Chapter(
                startDate: entry.startDate,
                endDate: entry.endDate,
                chapterNumber: index + 1
            )
            chapters.append(chapter)
        }

        let currentChapter = Chapter(
            startDate: clampedSelectableDate(historyCurrentStart),
            chapterNumber: sanitizedPreviousChapters.count + 1
        )
        chapters.append(currentChapter)

        store.importChapters(chapters)
    }

    private func clampedSelectableDate(_ date: Date) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let lowerBound = Calendar.current.startOfDay(for: selectableDateRange.lowerBound)
        let upperBound = Calendar.current.startOfDay(for: selectableDateRange.upperBound)
        return min(max(startOfDay, lowerBound), upperBound)
    }

    static func formatDate(_ date: Date) -> String {
        StackDateFormatter.string(from: date)
    }
}

private struct StackDatePicker: View {
    @Binding var selection: Date
    let range: ClosedRange<Date>

    @State private var displayedMonth: Date

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    init(selection: Binding<Date>, range: ClosedRange<Date>) {
        self._selection = selection
        self.range = range
        self._displayedMonth = State(initialValue: Self.startOfMonth(for: selection.wrappedValue))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button {
                    guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else { return }
                    displayedMonth = Self.startOfMonth(for: previousMonth)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(StackTypography.callout)
                        .foregroundStyle(canMoveBackward ? StackTheme.primaryText : StackTheme.secondaryText)
                        .frame(width: 44, height: 44)
                }
                .disabled(!canMoveBackward)

                Spacer()

                Text(monthTitle(for: displayedMonth))
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.primaryText)

                Spacer()

                Button {
                    guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return }
                    displayedMonth = Self.startOfMonth(for: nextMonth)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(StackTypography.callout)
                        .foregroundStyle(canMoveForward ? StackTheme.primaryText : StackTheme.secondaryText)
                        .frame(width: 44, height: 44)
                }
                .disabled(!canMoveForward)
            }

            weekdayHeader

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(dayCells.indices, id: \.self) { index in
                    if let date = dayCells[index] {
                        Button {
                            guard isSelectable(date) else { return }
                            selection = date
                        } label: {
                            Text(dayNumber(for: date))
                                .font(StackTypography.caption)
                                .foregroundStyle(dayForeground(for: date))
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(dayBackground(for: date))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(dayBorder(for: date), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(!isSelectable(date))
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }

            Text(OnboardingContainerView.formatDate(selection))
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.secondaryText)
        }
        .padding(18)
        .background(StackTheme.surface1)
        .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadius, style: .continuous))
        .onChange(of: selection) { _, newValue in
            let clamped = clampedSelection(newValue)
            if clamped != newValue {
                selection = clamped
            }
            displayedMonth = Self.startOfMonth(for: clamped)
        }
    }

    private var canMoveBackward: Bool {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else { return false }
        return Self.startOfMonth(for: previousMonth) >= Self.startOfMonth(for: range.lowerBound)
    }

    private var canMoveForward: Bool {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return false }
        return Self.startOfMonth(for: nextMonth) <= Self.startOfMonth(for: range.upperBound)
    }

    private var weekdayHeader: some View {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return HStack(spacing: 8) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(StackTypography.overline)
                    .foregroundStyle(StackTheme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayCells: [Date?] {
        let startOfMonth = Self.startOfMonth(for: displayedMonth)
        guard let dayRange = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }

        let weekday = calendar.component(.weekday, from: startOfMonth)
        let leadingEmptyDays = (weekday - calendar.firstWeekday + 7) % 7

        var cells = Array<Date?>(repeating: nil, count: leadingEmptyDays)

        for day in dayRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                cells.append(date)
            }
        }

        return cells
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func dayNumber(for date: Date) -> String {
        String(calendar.component(.day, from: date))
    }

    private func dayForeground(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: selection) {
            return StackTheme.background
        }
        return isSelectable(date) ? StackTheme.primaryText : StackTheme.secondaryText
    }

    private func dayBackground(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: selection) {
            return StackTheme.primaryText
        }
        return .clear
    }

    private func dayBorder(for date: Date) -> Color {
        if calendar.isDate(date, inSameDayAs: selection) {
            return StackTheme.primaryText
        }
        if calendar.isDateInToday(date) {
            return StackTheme.ember
        }
        return .clear
    }

    private func isSelectable(_ date: Date) -> Bool {
        range.contains(calendar.startOfDay(for: date))
    }

    private func clampedSelection(_ date: Date) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        let lowerBound = calendar.startOfDay(for: range.lowerBound)
        let upperBound = calendar.startOfDay(for: range.upperBound)
        return min(max(startOfDay, lowerBound), upperBound)
    }

    private static func startOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
}

private struct AnyButtonStyle: ButtonStyle {
    private let makeBodyClosure: (Configuration) -> AnyView

    init<Style: ButtonStyle>(_ style: Style) {
        self.makeBodyClosure = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        makeBodyClosure(configuration)
    }
}

struct PreviousChapterEntry: Identifiable {
    let id: String = UUID().uuidString
    let number: Int
    let startDate: Date
    let endDate: Date
}
