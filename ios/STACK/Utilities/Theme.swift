import SwiftUI

enum StackTheme {
    // Backgrounds
    static let background = Color(hex: "0C0B09")
    static let cardBackground = Color(hex: "1E1C19")
    static let cardBorder = Color(hex: "3A3836")

    // Text
    static let primaryText = Color(hex: "F4F2EE")
    static let secondaryText = Color(hex: "A09890")
    static let tertiaryText = Color(hex: "9B958E")
    static let ghost = Color(hex: "2E2C2A")
    static let milestoneWhite = Color.white
    static let separator = Color(hex: "1C1B19")

    // Accent
    static let gold = Color(hex: "C8A96E")

    // Destructive
    static let destructive = Color.red.opacity(0.8)
    static let destructiveMuted = Color.red.opacity(0.5)

    // Layout constants
    static let cardRadius: CGFloat = 16
    static let cardRadiusSmall: CGFloat = 12
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
    static let heroCounter = Font.system(size: 88, weight: .light)
    static let display = Font.system(size: 42, weight: .regular)
    static let title = Font.system(size: 34, weight: .regular)
    static let headline = Font.system(size: 22, weight: .medium)
    static let subheadline = Font.system(size: 18, weight: .regular)
    static let body = Font.system(size: 16, weight: .regular)
    static let callout = Font.system(size: 15, weight: .regular)
    static let cta = Font.system(size: 15, weight: .medium)
    static let footnote = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
    static let overline = Font.system(size: 13, weight: .medium)
    static let label = Font.system(size: 11, weight: .regular)
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
    static let pledgeRing = Animation.spring(duration: 0.6, bounce: 0.2)
    static let cardEntrance = Animation.spring(duration: 0.45, bounce: 0.12)
    static let entrance = Animation.easeOut(duration: 0.35)
    static let press = Animation.easeInOut(duration: 0.15)
    static let stagger: Double = 0.06
}

struct StackCard<Content: View>: View {
    let content: Content
    var padding: CGFloat
    var radius: CGFloat

    init(padding: CGFloat = 20, radius: CGFloat = StackTheme.cardRadius, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.radius = radius
    }

    var body: some View {
        content
            .padding(padding)
            .background(StackTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(StackTheme.cardBorder, lineWidth: 1.0))
    }
}

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

struct GoldCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StackTypography.cta)
            .foregroundStyle(StackTheme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(StackTheme.gold)
            .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(StackAnimation.press, value: configuration.isPressed)
    }
}

extension View {
    func entranceAnimation(visible: Bool, offset: CGFloat = 10) -> some View {
        self.opacity(visible ? 1 : 0).offset(y: visible ? 0 : offset)
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
