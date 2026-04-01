import SwiftUI

enum StackTheme {
    static let background = Color(hex: "0C0B09")
    static let primaryText = Color(hex: "F4F2EE")
    static let secondaryText = Color(hex: "A09890")
    static let tertiaryText = Color(hex: "8A857F")
    static let ghost = Color(hex: "2E2C2A")
    static let milestoneWhite = Color.white
    static let separator = Color(hex: "1C1B19")
    static let destructive = Color.red.opacity(0.8)
    static let destructiveMuted = Color.red.opacity(0.5)
}

enum StackDateFormatter {
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
