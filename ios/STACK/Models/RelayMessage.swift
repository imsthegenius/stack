import Foundation

nonisolated struct RelayMessage: Codable, Identifiable, Sendable {
    let id: String
    let milestoneDays: Int
    let text: String
    let createdAt: Date?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case milestoneDays = "milestone_days"
        case text
        case createdAt = "created_at"
        case isActive = "is_active"
    }
}
