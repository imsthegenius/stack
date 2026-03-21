import SwiftUI
import RevenueCat

@main
struct STACKApp: App {
    init() {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: "appl_GZCLVMbDdSbNaXDsuIJFpjafBRp")

        let lightFont34 = UIFont.systemFont(ofSize: 34, weight: .light)
        let lightFont17 = UIFont.systemFont(ofSize: 17, weight: .light)
        let primaryColor = UIColor(red: 244/255, green: 242/255, blue: 238/255, alpha: 1)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: lightFont34,
            .foregroundColor: primaryColor
        ]
        appearance.titleTextAttributes = [
            .font: lightFont17,
            .foregroundColor: primaryColor
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        let tertiaryColor = UIColor(red: 74/255, green: 72/255, blue: 69/255, alpha: 1)
        let tabFont = UIFont.systemFont(ofSize: 10, weight: .light)

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        tabAppearance.backgroundColor = UIColor(red: 12/255, green: 11/255, blue: 9/255, alpha: 1)
        tabAppearance.stackedLayoutAppearance.normal.iconColor = tertiaryColor
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tertiaryColor, .font: tabFont]
        tabAppearance.stackedLayoutAppearance.selected.iconColor = primaryColor
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: primaryColor, .font: tabFont]
        tabAppearance.inlineLayoutAppearance.normal.iconColor = tertiaryColor
        tabAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tertiaryColor, .font: tabFont]
        tabAppearance.inlineLayoutAppearance.selected.iconColor = primaryColor
        tabAppearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: primaryColor, .font: tabFont]
        tabAppearance.compactInlineLayoutAppearance.normal.iconColor = tertiaryColor
        tabAppearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: tertiaryColor, .font: tabFont]
        tabAppearance.compactInlineLayoutAppearance.selected.iconColor = primaryColor
        tabAppearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: primaryColor, .font: tabFont]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
