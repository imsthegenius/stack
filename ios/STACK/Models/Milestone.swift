import Foundation

// MARK: - Relay Point

nonisolated struct RelayPoint: Sendable {
    enum Presentation: Sendable {
        case inline
        case fullscreen
    }

    let day: Int
    let writerDay: Int
    let label: String
    let presentation: Presentation
    let isFree: Bool
    let isMilestone: Bool
    let writePrompt: String
    let writePlaceholder: String

    static let allRelayPoints: [RelayPoint] = [
        RelayPoint(day: 1,    writerDay: 7,    label: "Day 1",          presentation: .inline,     isFree: true,  isMilestone: true,  writePrompt: "Someone is on Day 1 right now. The very first day. What do you remember about yours?", writePlaceholder: "What was Day 1 like?"),
        RelayPoint(day: 2,    writerDay: 7,    label: "Day 2",          presentation: .inline,     isFree: true,  isMilestone: false, writePrompt: "Someone just finished Day 2. Still very early. What was that like for you?", writePlaceholder: "What do you remember about the second day?"),
        RelayPoint(day: 3,    writerDay: 14,   label: "Day 3",          presentation: .inline,     isFree: true,  isMilestone: false, writePrompt: "Write something for someone on Day 3. They've been at this for three days.", writePlaceholder: "What would you tell someone on Day 3?"),
        RelayPoint(day: 4,    writerDay: 14,   label: "Day 4",          presentation: .inline,     isFree: true,  isMilestone: false, writePrompt: "Someone is on Day 4. The middle of the first week. What would you tell them?", writePlaceholder: "What was the middle of the first week like?"),
        RelayPoint(day: 5,    writerDay: 14,   label: "Day 5",          presentation: .inline,     isFree: true,  isMilestone: false, writePrompt: "Write something for someone on Day 5. Almost through the first week.", writePlaceholder: "What do you remember about Day 5?"),
        RelayPoint(day: 6,    writerDay: 14,   label: "Day 6",          presentation: .inline,     isFree: true,  isMilestone: false, writePrompt: "Someone is on Day 6. Tomorrow is a full week. What do you remember about this point?", writePlaceholder: "The day before a full week. What was that like?"),
        RelayPoint(day: 7,    writerDay: 30,   label: "One Week",       presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Someone just hit one week. Write something for them.", writePlaceholder: "What do you remember about the first week?"),
        RelayPoint(day: 10,   writerDay: 30,   label: "Day 10",         presentation: .inline,     isFree: false, isMilestone: false, writePrompt: "Write something for someone on Day 10. Their first double-digit day.", writePlaceholder: "What was it like hitting double digits?"),
        RelayPoint(day: 14,   writerDay: 30,   label: "Two Weeks",      presentation: .fullscreen, isFree: false, isMilestone: false, writePrompt: "Someone just finished two weeks. What was that stretch like for you?", writePlaceholder: "What would you tell someone at two weeks?"),
        RelayPoint(day: 21,   writerDay: 60,   label: "Three Weeks",    presentation: .inline,     isFree: false, isMilestone: false, writePrompt: "Write something for someone at three weeks.", writePlaceholder: "What do you remember about three weeks in?"),
        RelayPoint(day: 30,   writerDay: 90,   label: "One Month",      presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Someone just hit one month. What would you want them to know?", writePlaceholder: "What would you tell someone at one month?"),
        RelayPoint(day: 45,   writerDay: 90,   label: "45 Days",        presentation: .inline,     isFree: false, isMilestone: false, writePrompt: "Write something for someone at 45 days. They're between milestones.", writePlaceholder: "What was it like between one month and two?"),
        RelayPoint(day: 60,   writerDay: 180,  label: "Two Months",     presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Someone just reached two months. Write something for them.", writePlaceholder: "What do you remember about two months?"),
        RelayPoint(day: 90,   writerDay: 180,  label: "Three Months",   presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Write something for someone at three months. The first big number.", writePlaceholder: "What was three months like?"),
        RelayPoint(day: 120,  writerDay: 270,  label: "Four Months",    presentation: .inline,     isFree: false, isMilestone: false, writePrompt: "Someone is at four months. Write something for them.", writePlaceholder: "What do you remember about four months in?"),
        RelayPoint(day: 150,  writerDay: 365,  label: "Five Months",    presentation: .inline,     isFree: false, isMilestone: false, writePrompt: "Write something for someone at five months. They're halfway to a year.", writePlaceholder: "What was it like halfway to a year?"),
        RelayPoint(day: 180,  writerDay: 365,  label: "Six Months",     presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Someone just hit six months. What do you remember about that point?", writePlaceholder: "What do you remember about six months?"),
        RelayPoint(day: 270,  writerDay: 365,  label: "Nine Months",    presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Write something for someone at nine months.", writePlaceholder: "What was nine months like?"),
        RelayPoint(day: 365,  writerDay: 730,  label: "One Year",       presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Someone just hit one year. You've been there. What would you tell them?", writePlaceholder: "What would you tell someone at one year?"),
        RelayPoint(day: 500,  writerDay: 1000, label: "500 Days",       presentation: .fullscreen, isFree: false, isMilestone: false, writePrompt: "Write something for someone at 500 days.", writePlaceholder: "What do you remember about 500 days?"),
        RelayPoint(day: 730,  writerDay: 1825, label: "Two Years",      presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Someone just hit two years. Write something for them.", writePlaceholder: "What would you tell someone at two years?"),
        RelayPoint(day: 1000, writerDay: 1825, label: "The Comma Club", presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Write something for someone at 1000 days. The Comma Club.", writePlaceholder: "What would you tell someone at 1000 days?"),
        RelayPoint(day: 1825, writerDay: 3650, label: "Five Years",     presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Someone just reached five years. Write something for them.", writePlaceholder: "What would you tell someone at five years?"),
        RelayPoint(day: 3650, writerDay: 7300, label: "Ten Years",      presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "Write something for someone at ten years.", writePlaceholder: "What would you tell someone at ten years?"),
        RelayPoint(day: 7300, writerDay: 7300, label: "Twenty Years",   presentation: .fullscreen, isFree: false, isMilestone: true,  writePrompt: "You're one of the longest-standing people in STACK. Write something for someone behind you.", writePlaceholder: "What would you say to someone on this path?"),
    ]

    static func isRelayDay(_ day: Int) -> Bool {
        allRelayPoints.contains { $0.day == day }
    }

    static func relayPoint(for day: Int) -> RelayPoint? {
        allRelayPoints.first { $0.day == day }
    }

    static func nextRelayPoint(after day: Int) -> RelayPoint? {
        allRelayPoints.first { $0.day > day }
    }
}

// MARK: - Milestone

nonisolated enum Milestone: Sendable {
    // All 25 relay points — drives Stacks view, matches relay cadence exactly
    static let allDays: [Int] = RelayPoint.allRelayPoints.map { $0.day }

    static func label(for days: Int) -> String? {
        RelayPoint.relayPoint(for: days)?.label
    }

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
