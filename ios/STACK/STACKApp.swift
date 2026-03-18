import SwiftUI

@main
struct STACKApp: App {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .light),
            .foregroundColor: UIColor(red: 244/255, green: 242/255, blue: 238/255, alpha: 1)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .light),
            .foregroundColor: UIColor(red: 244/255, green: 242/255, blue: 238/255, alpha: 1)
        ]
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
