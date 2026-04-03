import SwiftUI
import RevenueCat

@main
struct STACKApp: App {
    init() {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: "appl_GZCLVMbDdSbNaXDsuIJFpjafBRp")

        let primaryColor = UIColor.white
        let secondaryColor = UIColor(red: 160/255, green: 152/255, blue: 144/255, alpha: 1)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .light),
            .foregroundColor: primaryColor
        ]
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .light),
            .foregroundColor: primaryColor
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        let tabFont = UIFont.systemFont(ofSize: 10, weight: .regular)

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithDefaultBackground()
        tabAppearance.backgroundColor = UIColor(red: 12/255, green: 11/255, blue: 9/255, alpha: 1)
        tabAppearance.stackedLayoutAppearance.normal.iconColor = secondaryColor
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: secondaryColor, .font: tabFont]
        tabAppearance.stackedLayoutAppearance.selected.iconColor = primaryColor
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: primaryColor, .font: tabFont]
        tabAppearance.inlineLayoutAppearance.normal.iconColor = secondaryColor
        tabAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: secondaryColor, .font: tabFont]
        tabAppearance.inlineLayoutAppearance.selected.iconColor = primaryColor
        tabAppearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: primaryColor, .font: tabFont]
        tabAppearance.compactInlineLayoutAppearance.normal.iconColor = secondaryColor
        tabAppearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: secondaryColor, .font: tabFont]
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
