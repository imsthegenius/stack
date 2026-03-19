import Foundation

nonisolated struct RelayMessage: Codable, Identifiable, Sendable {
    let id: String
    let text: String
    let createdAt: Date?
    let isActive: Bool?

    // v2 fields
    let targetDay: Int?
    let writerDay: Int?
    let isSeed: Bool?

    // v1 backward compat
    let milestoneDays: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case createdAt = "created_at"
        case isActive = "is_active"
        case targetDay = "target_day"
        case writerDay = "writer_day"
        case isSeed = "is_seed"
        case milestoneDays = "milestone_days"
    }
}
