import SwiftUI
import RevenueCat

struct SettingsView: View {
    let store: StackStore
    @State private var showWidgetInstructions: Bool = false
    @State private var showPaywall: Bool = false
    @State private var isRestoring: Bool = false
    @State private var priceString: String = ""
    @State private var showDeleteConfirmation: Bool = false
    @State private var isDeletingAccount: Bool = false
    @State private var deleteError: Bool = false
    @State private var showSignInSheet: Bool = false
    @State private var showNewChapterConfirmation: Bool = false
    private var auth: AuthService { AuthService.shared }

    var body: some View {
        NavigationStack {
            List {
                Text("Settings")
                    .font(StackTypography.title)
                    .foregroundStyle(StackTheme.primaryText)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 16, leading: 28, bottom: 8, trailing: 28))

                Section {
                    Button { showWidgetInstructions = true } label: {
                        settingsRow("Add to lock screen") {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(StackTheme.secondaryText)
                        }
                    }
                    .listRowBackground(StackTheme.surface1)
                    .listRowSeparatorTint(StackTheme.separator)
                } header: {
                    overlineHeader("WIDGET")
                }

                Section {
                    if store.lifetimePurchased {
                        settingsRow("Lifetime \u{00B7} Unlocked") { EmptyView() }
                            .listRowBackground(StackTheme.surface1)
                            .listRowSeparatorTint(StackTheme.separator)
                    } else {
                        Button { showPaywall = true } label: {
                            settingsRow("Unlock STACK") {
                                if !priceString.isEmpty {
                                    Text("\u{00B7} \(priceString)")
                                        .font(StackTypography.footnote)
                                        .foregroundStyle(StackTheme.ember)
                                }
                            }
                        }
                        .listRowBackground(StackTheme.surface1)
                        .listRowSeparatorTint(StackTheme.separator)

                        Button {
                            Task { await restoreSettingsPurchases() }
                        } label: {
                            HStack {
                                Text("Restore purchases")
                                    .font(StackTypography.callout)
                                    .foregroundStyle(StackTheme.secondaryText)
                                Spacer()
                                if isRestoring {
                                    ProgressView()
                                        .tint(StackTheme.secondaryText)
                                        .scaleEffect(0.75)
                                }
                            }
                        }
                        .disabled(isRestoring)
                        .listRowBackground(StackTheme.surface1)
                        .listRowSeparatorTint(StackTheme.separator)
                    }

                    Button { showNewChapterConfirmation = true } label: {
                        settingsRow("Start New Chapter") {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(StackTheme.secondaryText)
                        }
                    }
                    .listRowBackground(StackTheme.surface1)
                    .listRowSeparatorTint(StackTheme.separator)
                } header: {
                    overlineHeader("STACK")
                }

                Section {
                    if auth.isSignedIn {
                        if let email = auth.userEmail {
                            settingsRow(email) { EmptyView() }
                                .listRowBackground(StackTheme.surface1)
                                .listRowSeparatorTint(StackTheme.separator)
                        }

                        Button { auth.signOut() } label: {
                            settingsRow("Sign Out") { EmptyView() }
                        }
                        .listRowBackground(StackTheme.surface1)
                        .listRowSeparatorTint(StackTheme.separator)
                    } else {
                        Button { showSignInSheet = true } label: {
                            settingsRow("Sign in with Apple") {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(StackTheme.secondaryText)
                            }
                        }
                        .listRowBackground(StackTheme.surface1)
                        .listRowSeparatorTint(StackTheme.separator)
                    }
                } header: {
                    overlineHeader("ACCOUNT")
                }

                if auth.isSignedIn {
                    Section {
                        Button { showDeleteConfirmation = true } label: {
                            HStack {
                                Text("Delete Account")
                                    .font(StackTypography.callout)
                                    .foregroundStyle(StackTheme.destructive)
                                Spacer()
                                if isDeletingAccount {
                                    ProgressView()
                                        .tint(StackTheme.destructiveMuted)
                                        .scaleEffect(0.75)
                                }
                            }
                        }
                        .disabled(isDeletingAccount)
                        .listRowBackground(StackTheme.surface1)
                    }
                }

                Section {
                    Link(destination: URL(string: "https://stack.twohundred.ai/privacy.html")!) {
                        settingsRow("Privacy Policy") {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(StackTheme.secondaryText)
                        }
                    }
                    .listRowBackground(StackTheme.surface1)
                    .listRowSeparatorTint(StackTheme.separator)

                    Link(destination: URL(string: "https://stack.twohundred.ai/terms.html")!) {
                        settingsRow("Terms of Use") {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(StackTheme.secondaryText)
                        }
                    }
                    .listRowBackground(StackTheme.surface1)
                    .listRowSeparatorTint(StackTheme.separator)

                    Link(destination: URL(string: "mailto:hello@twohundred.ai")!) {
                        settingsRow("Contact Support") {
                            Image(systemName: "envelope")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(StackTheme.secondaryText)
                        }
                    }
                    .listRowBackground(StackTheme.surface1)
                    .listRowSeparatorTint(StackTheme.separator)
                } header: {
                    overlineHeader("LEGAL")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            Text("Version \(version)")
                                .font(StackTypography.overline)
                                .foregroundStyle(StackTheme.secondaryText)
                        }

                        Text("No notifications. No streaks. No social.")
                            .font(StackTypography.overline)
                            .foregroundStyle(StackTheme.secondaryText)

                        Text(auth.isSignedIn
                             ? "Your data is backed up when signed in."
                             : "Sign in to back up your progress across devices.")
                            .font(StackTypography.caption)
                            .foregroundStyle(StackTheme.secondaryText)
                    }
                    .listRowBackground(StackTheme.surface1)
                } header: {
                    overlineHeader("ABOUT")
                }

                #if DEBUG
                debugSection
                #endif
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(StackTheme.background)
            .navigationTitle("")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showWidgetInstructions) {
                WidgetInstructionsSheet()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(store: store)
            }
            .sheet(isPresented: $showSignInSheet) {
                SignInView(store: store)
            }
            .alert("Delete Account", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task { await performAccountDeletion() }
                }
            } message: {
                Text("This permanently deletes your account and all synced data. Your local data will also be erased. This cannot be undone.")
            }
            .alert("Start New Chapter", isPresented: $showNewChapterConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Start") {
                    store.startNewChapter()
                }
            } message: {
                let days = store.currentDays
                let chapter = store.currentChapter?.chapterNumber ?? 1
                Text("Your \(days) days in Chapter \(chapter) stay in your Journey forever. Your counter resets to Day 1, starting today.")
            }
            .alert("Could Not Delete", isPresented: $deleteError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please check your connection and try again.")
            }
            .task {
                await loadPrice()
            }
        }
    }

    // MARK: - Helpers

    private func settingsRow<Trailing: View>(_ title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack {
            Text(title)
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.primaryText)
            Spacer()
            trailing()
        }
    }

    private func overlineHeader(_ title: String) -> some View {
        Text(title)
            .font(StackTypography.overline)
            .tracking(1.5)
            .foregroundStyle(StackTheme.secondaryText)
            .textCase(nil)
    }

    // MARK: - Actions

    private func loadPrice() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            if let price = offerings.current?.lifetime?.storeProduct.localizedPriceString {
                priceString = price
            }
        } catch {
            // Price won't display
        }
    }

    private func performAccountDeletion() async {
        isDeletingAccount = true
        defer { isDeletingAccount = false }
        let success = await AuthService.shared.deleteAccount()
        if success {
            store.resetForAccountDeletion()
        } else {
            deleteError = true
        }
    }

    private func restoreSettingsPurchases() async {
        isRestoring = true
        defer { isRestoring = false }
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let active = customerInfo.entitlements["Stack Forever"]?.isActive == true
            store.lifetimePurchased = active
            store.save()
        } catch {
            // Restore failed silently
        }
    }

    // MARK: - Debug

    #if DEBUG
    @State private var debugDay: Int = 1
    private let debugRelayDays = [1, 2, 3, 7, 14, 30, 60, 90, 180, 365, 1000]

    private var debugSection: some View {
        Section {
            HStack {
                Text("Jump to day")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.primaryText)
                Spacer()
                Picker("Day", selection: $debugDay) {
                    ForEach(debugRelayDays, id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }
                .tint(StackTheme.secondaryText)
            }
            .listRowBackground(StackTheme.surface1)

            Button {
                guard let chapter = store.currentChapter,
                      let index = store.chapters.firstIndex(where: { $0.id == chapter.id }) else { return }
                let newStart = Calendar.current.date(byAdding: .day, value: -debugDay, to: Calendar.current.startOfDay(for: Date()))!
                store.chapters[index] = Chapter(id: chapter.id, startDate: newStart, endDate: chapter.endDate, chapterNumber: chapter.chapterNumber)
                store.todayPledgeDate = nil
                store.receivedRelayDays = []
                store.blockedRelayMessageIDs = []
                store.save()
            } label: {
                Text("Set day to \(debugDay) & reset pledge")
                    .font(StackTypography.caption)
                    .foregroundStyle(StackTheme.secondaryText)
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(StackTheme.surface1)

            Toggle(isOn: Binding(
                get: { store.lifetimePurchased },
                set: { store.lifetimePurchased = $0; store.save() }
            )) {
                Text("Force paid (screenshots)")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.primaryText)
            }
            .tint(StackTheme.ember)
            .listRowBackground(StackTheme.surface1)
        } header: {
            overlineHeader("DEBUG (stripped from release)")
        }
    }
    #endif
}

struct WidgetInstructionsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    instructionStep(number: 1, icon: "lock.fill", text: "Long press on your Lock Screen")
                    instructionStep(number: 2, icon: "plus.circle", text: "Tap \"Customize\" then \"Lock Screen\"")
                    instructionStep(number: 3, icon: "rectangle.grid.1x2", text: "Tap the widget area above or below the clock")
                    instructionStep(number: 4, icon: "magnifyingglass", text: "Search for \"STACK\" and select a widget")
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
            }
            .background(StackTheme.background)
            .navigationTitle("Add Widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StackTheme.secondaryText)
                }
            }
        }
    }

    private func instructionStep(number: Int, icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(StackTheme.surface2)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(StackTheme.secondaryText)
            }

            Text(text)
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.primaryText)
        }
    }
}
