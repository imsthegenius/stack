import Foundation

nonisolated struct Chapter: Codable, Identifiable, Sendable {
    let id: String
    let startDate: Date
    var endDate: Date?
    let chapterNumber: Int

    var isCurrentChapter: Bool { endDate == nil }

    var daysCount: Int {
        let end = endDate ?? Date()
        return max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate), to: Calendar.current.startOfDay(for: end)).day ?? 0)
    }

    init(id: String = UUID().uuidString, startDate: Date, endDate: Date? = nil, chapterNumber: Int) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.chapterNumber = chapterNumber
    }
}
