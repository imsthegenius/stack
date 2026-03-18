import Foundation
import WidgetKit

@Observable
class StackStore {
    var chapters: [Chapter] = []
    var todayPledgeDate: String?
    var hasCompletedOnboarding: Bool = false
    var lifetimePurchased: Bool = false
    var receivedRelayMilestoneDays: [Int] = []

    private let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: "group.com.stack.shared") ?? .standard
        load()
    }

    var currentChapter: Chapter? { chapters.first(where: { $0.isCurrentChapter }) }
    var currentDays: Int { currentChapter?.daysCount ?? 0 }
    var totalDays: Int { chapters.reduce(0) { $0 + $1.daysCount } }
    var milestonesEarned: [Int] { Milestone.allDays.filter { currentDays >= $0 } }
    var isMilestoneDay: Bool { Milestone.allDays.contains(currentDays) }
    var currentMilestoneLabel: String? { Milestone.label(for: currentDays) }

    var hasPledgedToday: Bool {
        let todayString = Self.dateString(from: Date())
        return todayPledgeDate == todayString
    }

    var sortedChapters: [Chapter] {
        chapters.sorted { $0.chapterNumber > $1.chapterNumber }
    }

    func pledgeToday() {
        let todayString = Self.dateString(from: Date())
        todayPledgeDate = todayString
        defaults.set(todayString, forKey: "today_pledge_date")
        syncWidgetData()
    }

    func startNewChapter() {
        guard var current = currentChapter else { return }
        let today = Calendar.current.startOfDay(for: Date())
        current.endDate = today
        if let index = chapters.firstIndex(where: { $0.id == current.id }) {
            chapters[index] = current
        }
        let newChapter = Chapter(
            startDate: today,
            chapterNumber: current.chapterNumber + 1
        )
        chapters.append(newChapter)
        save()
    }

    func createInitialChapter(startDate: Date) {
        let chapter = Chapter(
            startDate: Calendar.current.startOfDay(for: startDate),
            chapterNumber: 1
        )
        chapters = [chapter]
        hasCompletedOnboarding = true
        save()
    }

    func importChapters(_ importedChapters: [Chapter]) {
        chapters = importedChapters
        hasCompletedOnboarding = true
        save()
    }

    func earnedDate(for milestoneDays: Int) -> (date: Date, chapter: Chapter)? {
        guard let chapter = currentChapter else { return nil }
        guard chapter.daysCount >= milestoneDays else { return nil }
        let earnedDate = Calendar.current.date(byAdding: .day, value: milestoneDays, to: Calendar.current.startOfDay(for: chapter.startDate))
        return (earnedDate ?? Date(), chapter)
    }

    func load() {
        if let data = defaults.data(forKey: "chapters_data"),
           let decoded = try? JSONDecoder().decode([Chapter].self, from: data) {
            chapters = decoded
        }
        todayPledgeDate = defaults.string(forKey: "today_pledge_date")
        hasCompletedOnboarding = defaults.bool(forKey: "has_completed_onboarding")
        lifetimePurchased = defaults.bool(forKey: "lifetime_purchased")
        if let relayData = defaults.array(forKey: "received_relay_milestone_days") as? [Int] {
            receivedRelayMilestoneDays = relayData
        }
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(chapters) {
            defaults.set(encoded, forKey: "chapters_data")
        }
        defaults.set(hasCompletedOnboarding, forKey: "has_completed_onboarding")
        defaults.set(lifetimePurchased, forKey: "lifetime_purchased")
        defaults.set(receivedRelayMilestoneDays, forKey: "received_relay_milestone_days")
        syncWidgetData()
    }

    func syncWidgetData() {
        defaults.set(currentDays, forKey: "widget_current_days")
        defaults.set(currentChapter?.chapterNumber ?? 1, forKey: "widget_chapter_number")
        defaults.set(totalDays, forKey: "widget_total_days")
        defaults.set(isMilestoneDay, forKey: "widget_is_milestone_today")
        defaults.set(hasPledgedToday, forKey: "widget_pledged_today")
        defaults.set(currentMilestoneLabel ?? "", forKey: "widget_milestone_label")
        WidgetCenter.shared.reloadAllTimelines()
    }

    private static func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
