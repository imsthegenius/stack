import SwiftUI
import RevenueCat

struct ContentView: View {
    @State private var store = StackStore()
    @State private var selectedTab: Int = 0
    private var auth: AuthService { AuthService.shared }

    private var requiresSignIn: Bool {
        #if DEBUG
        return !auth.isSignedIn && !auth.hasSkippedSignIn
        #else
        return !auth.isSignedIn
        #endif
    }

    var body: some View {
        Group {
            if !store.hasCompletedOnboarding {
                OnboardingContainerView(store: store)
            } else if requiresSignIn {
                SignInView(store: store)
            } else if store.chapters.isEmpty {
                // Signed in but no data (e.g. wrong Apple ID, new account) — redirect to setup
                OnboardingContainerView(store: store)
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
                .tabItem { Label("Today", systemImage: "circle") }
                .tag(0)

            StacksView(store: store)
                .tabItem { Label("Stacks", systemImage: "square.stack") }
                .tag(1)

            JourneyView(store: store)
                .tabItem { Label("Journey", systemImage: "book.pages") }
                .tag(2)

            SettingsView(store: store)
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
        }
        .tint(StackTheme.primaryText)
    }
}
