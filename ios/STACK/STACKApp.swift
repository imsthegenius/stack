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
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
