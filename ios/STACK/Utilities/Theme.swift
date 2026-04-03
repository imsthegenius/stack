import SwiftUI

// MARK: - Color System

enum StackTheme {
    // 4-tier warm dark surfaces
    static let background = Color(hex: "0C0B09")
    static let surface1 = Color(hex: "14120F")
    static let surface2 = Color(hex: "1C1916")
    static let surface3 = Color(hex: "252220")

    // Text — true white body, warm secondary
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "A09890")
    static let ghost = Color(hex: "2E2C2A")
    static let milestoneWhite = Color.white
    static let separator = Color(hex: "1C1B19")

    // Accent — ember orange (replaces gold)
    static let ember = Color(hex: "CB6040")

    // Ember perceptual scale
    static let ember10 = Color(hex: "FEF3EF")
    static let ember20 = Color(hex: "F9D5C8")
    static let ember30 = Color(hex: "F0B5A0")
    static let ember40 = Color(hex: "E09478")
    static let ember50 = Color(hex: "CB6040") // primary
    static let ember60 = Color(hex: "B04E32")
    static let ember70 = Color(hex: "8F3D26")
    static let ember80 = Color(hex: "6E2E1C")
    static let ember90 = Color(hex: "502114")
    static let ember100 = Color(hex: "3E1A11")

    // Backward compat — gold maps to ember for existing views
    // View tickets (TWO-347..354) will replace these references
    static let gold = ember
    static let tertiaryText = secondaryText

    // Legacy card colors — mapped to new surface tiers
    static let cardBackground = surface2
    static let cardBorder = Color(hex: "3A3836")

    // Destructive
    static let destructive = Color.red.opacity(0.8)
    static let destructiveMuted = Color.red.opacity(0.5)

    // Layout constants
    static let cardRadius: CGFloat = 16
    static let cardRadiusSmall: CGFloat = 12
}

// MARK: - Typography

enum StackTypography {
    // SF Pro Thin — counter only
    static let heroCounter = Font.system(size: 88, weight: .thin)

    // Instrument Serif — headings
    static let display = Font.custom("InstrumentSerif-Regular", size: 38)
    static let title = Font.custom("InstrumentSerif-Regular", size: 28)
    static let subhead = Font.custom("InstrumentSerif-Regular", size: 22)

    // SF Pro Regular/Light — body and UI
    static let headline = Font.system(size: 20, weight: .light)
    static let body = Font.system(size: 17, weight: .regular)
    static let callout = Font.system(size: 16, weight: .regular)
    static let footnote = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 14, weight: .regular)
    static let overline = Font.system(size: 13, weight: .regular)

    // Georgia — relay messages only
    static let relay = Font.custom("Georgia", size: 19)

    // CTA — SF Pro Regular (no .medium)
    static let cta = Font.system(size: 16, weight: .regular)

    // Tracking helper for overlines
    static func tracked(_ font: Font, spacing: CGFloat = 1.5) -> some View {
        Text("").font(font).tracking(spacing)
    }
}

// MARK: - Spacing

enum StackSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let horizontalPadding: CGFloat = 28
}

// MARK: - Animation

enum StackAnimation {
    // Spring as default (per V4 spec)
    static let pledgeRing = Animation.spring(duration: 0.6, bounce: 0.2)
    static let cardEntrance = Animation.spring(duration: 0.45, bounce: 0.12)
    static let entrance = Animation.spring(duration: 0.5, bounce: 0.15)
    static let press = Animation.spring(duration: 0.2, bounce: 0.1)
    static let stagger: Double = 0.06
    static let timelineDraw = Animation.easeOut(duration: 0.6)
}

// MARK: - Haptics

enum StackHaptics {
    static func pledge() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func milestone() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    static func relayArrival() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func cta() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func tabSwitch() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func newChapter() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

// MARK: - Date Formatting

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

// MARK: - Card Component

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
            .background(StackTheme.surface2)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

// MARK: - Relay Card (ember left-border treatment)

struct RelayCard<Content: View>: View {
    let content: Content
    var padding: CGFloat

    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 1)
                .fill(StackTheme.ember)
                .frame(width: 2)

            content
                .padding(padding)
        }
        .background(StackTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadius, style: .continuous))
    }
}

// MARK: - Skeleton View

struct SkeletonView: View {
    @State private var shimmerOffset: CGFloat = -1

    var width: CGFloat = .infinity
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 8

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(StackTheme.surface3)
            .frame(maxWidth: width == .infinity ? .infinity : width, minHeight: height, maxHeight: height)
            .overlay(
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.clear, StackTheme.ghost.opacity(0.4), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset * geometry.size.width)
                }
                .clipped()
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmerOffset = 2
                }
            }
    }
}

// MARK: - Button Styles

struct PrimaryCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StackTypography.cta)
            .foregroundStyle(StackTheme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(StackAnimation.press, value: configuration.isPressed)
    }
}

struct EmberCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StackTypography.cta)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(StackTheme.ember)
            .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(StackAnimation.press, value: configuration.isPressed)
    }
}

// Backward compat alias
typealias GoldCTAButtonStyle = EmberCTAButtonStyle

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StackTypography.cta)
            .foregroundStyle(StackTheme.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(StackTheme.surface3)
            .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(StackAnimation.press, value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func entranceAnimation(visible: Bool, offset: CGFloat = 10) -> some View {
        self.opacity(visible ? 1 : 0).offset(y: visible ? 0 : offset)
    }
}

// MARK: - Color Hex Extension

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
