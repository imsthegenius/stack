import SwiftUI
import RevenueCat
import RevenueCatUI

struct SettingsView: View {
    let store: StackStore
    @State private var showWidgetInstructions: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showCustomerCenter: Bool = false
    @State private var isRestoring: Bool = false
    @State private var priceString: String = ""

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

                        StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                        Button {
                            showCustomerCenter = true
                        } label: {
                            settingsRow(title: "Manage", trailing: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundStyle(StackTheme.tertiaryText)
                            })
                        }
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

                    sectionHeader("LEGAL")
                        .padding(.top, 24)

                    Link(destination: URL(string: "https://imsthegenius.github.io/stack/privacy.html")!) {
                        settingsRow(title: "Privacy Policy", trailing: {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        })
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    Link(destination: URL(string: "https://imsthegenius.github.io/stack/terms.html")!) {
                        settingsRow(title: "Terms of Use", trailing: {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        })
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    Link(destination: URL(string: "mailto:hello@twohundred.co")!) {
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

                        Text("Relay messages are the only data that leaves your device.")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(StackTheme.tertiaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
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
            .sheet(isPresented: $showCustomerCenter) {
                CustomerCenterView()
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
