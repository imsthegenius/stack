import SwiftUI
import RevenueCat

struct ContentView: View {
    @State private var store = StackStore()
    @State private var selectedTab: Int = 0
    private var auth: AuthService { AuthService.shared }

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingContainerView(store: store)
            } else if !auth.isSignedIn && !auth.hasSkippedSignIn {
                SignInView(store: store)
            } else {
                mainTabView
            }
        }
        .preferredColorScheme(.dark)
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                let active = customerInfo.entitlements["Stack Forever"]?.isActive == true
                if store.lifetimePurchased != active {
                    store.lifetimePurchased = active
                    store.save()
                }
            }
        }
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
