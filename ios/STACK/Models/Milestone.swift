import Foundation

nonisolated enum Milestone: Sendable {
    static let allDays: [Int] = [1, 7, 30, 60, 90, 180, 270, 365, 730, 1000, 1825, 3650, 7300]

    static let labels: [Int: String] = [
        1: "24 Hours",
        7: "One Week",
        30: "One Month",
        60: "Two Months",
        90: "Three Months",
        180: "Six Months",
        270: "Nine Months",
        365: "One Year",
        730: "Two Years",
        1000: "The Comma Club",
        1825: "Five Years",
        3650: "Ten Years",
        7300: "Twenty Years"
    ]

    static func label(for days: Int) -> String? { labels[days] }

    static func shortLabel(for days: Int) -> String {
        switch days {
        case 365: return "1Y"
        case 730: return "2Y"
        case 1825: return "5Y"
        case 3650: return "10Y"
        case 7300: return "20Y"
        default: return "\(days)"
        }
    }

    static func daysUntil(from currentDays: Int, to milestoneDays: Int) -> Int {
        milestoneDays - currentDays
    }
}
