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

enum StackTypography {
    static let heroCounter = Font.system(size: 88, weight: .thin)
    static let title = Font.system(size: 22, weight: .light)
    static let headline = Font.system(size: 18, weight: .light)
    static let body = Font.system(size: 16, weight: .regular)
    static let callout = Font.system(size: 15, weight: .regular)
    static let subheadline = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let overline = Font.system(size: 11, weight: .regular)
    static let label = Font.system(size: 10, weight: .regular)
}

enum StackSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let horizontalPadding: CGFloat = 28
}

enum StackAnimation {
    static let pledgeRing = Animation.spring(duration: 0.5, bounce: 0.15)
    static let entrance = Animation.easeOut(duration: 0.3)
    static let press = Animation.easeInOut(duration: 0.15)
    static let stagger: Double = 0.08
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
