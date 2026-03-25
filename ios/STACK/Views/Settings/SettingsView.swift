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
            ScrollView {
                VStack(spacing: 0) {
                    Text("Settings")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(StackTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    sectionHeader("WIDGET")

                    Button {
                        showWidgetInstructions = true
                    } label: {
                        settingsRow(title: "Add to lock screen", trailing: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        })
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    sectionHeader("STACK")
                        .padding(.top, 24)

                    if store.lifetimePurchased {
                        settingsRow(title: "Lifetime · Unlocked", trailing: { EmptyView() })
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            settingsRow(title: "Unlock STACK", trailing: {
                                if !priceString.isEmpty {
                                    Text("· \(priceString)")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundStyle(StackTheme.tertiaryText)
                                }
                            })
                        }

                        StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                        Button {
                            Task { await restoreSettingsPurchases() }
                        } label: {
                            HStack {
                                Text("Restore purchases")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(StackTheme.tertiaryText)
                                Spacer()
                                if isRestoring {
                                    ProgressView()
                                        .tint(StackTheme.tertiaryText)
                                        .scaleEffect(0.75)
                                }
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                            .contentShape(Rectangle())
                        }
                        .disabled(isRestoring)
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    Button {
                        showNewChapterConfirmation = true
                    } label: {
                        settingsRow(title: "Start New Chapter", trailing: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        })
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    sectionHeader("ACCOUNT")
                        .padding(.top, 24)

                    if auth.isSignedIn {
                        if let email = auth.userEmail {
                            settingsRow(title: email, trailing: { EmptyView() })
                            StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)
                        }

                        Button {
                            auth.signOut()
                        } label: {
                            settingsRow(title: "Sign Out", trailing: { EmptyView() })
                        }

                        StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Text("Delete Account")
                                    .font(.system(size: 16, weight: .light))
                                    .foregroundStyle(.red.opacity(0.8))
                                Spacer()
                                if isDeletingAccount {
                                    ProgressView()
                                        .tint(.red.opacity(0.5))
                                        .scaleEffect(0.75)
                                }
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                            .contentShape(Rectangle())
                        }
                        .disabled(isDeletingAccount)
                    } else {
                        Button {
                            showSignInSheet = true
                        } label: {
                            settingsRow(title: "Sign in with Apple", trailing: {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(StackTheme.secondaryText)
                            })
                        }
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    sectionHeader("LEGAL")
                        .padding(.top, 24)

                    Link(destination: URL(string: "https://stack.twohundred.ai/privacy.html")!) {
                        settingsRow(title: "Privacy Policy", trailing: {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        })
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    Link(destination: URL(string: "https://stack.twohundred.ai/terms.html")!) {
                        settingsRow(title: "Terms of Use", trailing: {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        })
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    Link(destination: URL(string: "mailto:hello@twohundred.ai")!) {
                        settingsRow(title: "Contact Support", trailing: {
                            Image(systemName: "envelope")
                                .font(.system(size: 12, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        })
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    sectionHeader("ABOUT")
                        .padding(.top, 24)

                    VStack(alignment: .leading, spacing: 12) {
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            Text("Version \(version)")
                                .font(.system(size: 13, weight: .light))
                                .foregroundStyle(StackTheme.secondaryText)
                        }

                        Text("No notifications. No streaks. No social.")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(StackTheme.secondaryText)

                        Text(auth.isSignedIn
                             ? "Your data is backed up when signed in."
                             : "Sign in to back up your progress across devices.")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(StackTheme.tertiaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)

                    #if DEBUG
                    debugSection
                    #endif
                }
                .padding(.top, 8)
            }
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

    #if DEBUG
    @State private var debugDay: Int = 1
    private let debugRelayDays = [1, 2, 3, 7, 14, 30, 60, 90, 180, 365, 1000]

    private var debugSection: some View {
        VStack(spacing: 0) {
            sectionHeader("DEBUG (stripped from release)")
                .padding(.top, 24)

            HStack {
                Text("Jump to day")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(StackTheme.primaryText)
                Spacer()
                Picker("Day", selection: $debugDay) {
                    ForEach(debugRelayDays, id: \.self) { day in
                        Text("\(day)").tag(day)
                    }
                }
                .tint(StackTheme.secondaryText)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 12)

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
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }

            StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

            Toggle(isOn: Binding(
                get: { store.lifetimePurchased },
                set: { store.lifetimePurchased = $0; store.save() }
            )) {
                Text("Force paid (screenshots)")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(StackTheme.primaryText)
            }
            .tint(Color(hex: "C8A96E"))
            .padding(.horizontal, 28)
            .padding(.vertical, 12)

            StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)
        }
    }
    #endif

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .light))
            .tracking(1.5)
            .foregroundStyle(StackTheme.tertiaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }

    private func settingsRow<Trailing: View>(title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(StackTheme.primaryText)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
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
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(StackTheme.secondaryText)
                }
            }
        }
    }

    private func instructionStep(number: Int, icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(StackTheme.ghost, lineWidth: 1)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)
            }

            Text(text)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(StackTheme.primaryText)
        }
    }
}
