import SwiftUI

struct ContentView: View {
    @State private var store = StackStore()
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingContainerView(store: store)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            TodayView(store: store, switchToJourneyTab: { selectedTab = 2 })
                .tabItem { Text("Today") }
                .tag(0)

            StacksView(store: store)
                .tabItem { Text("Stacks") }
                .tag(1)

            JourneyView(store: store)
                .tabItem { Text("Journey") }
                .tag(2)

            SettingsView(store: store)
                .tabItem { Text("Settings") }
                .tag(3)
        }
        .tint(StackTheme.primaryText)
    }
}
