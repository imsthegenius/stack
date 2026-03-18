import SwiftUI

struct SettingsView: View {
    let store: StackStore
    @State private var showWidgetInstructions: Bool = false
    @State private var showPaywall: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    sectionHeader("WIDGET")

                    Button {
                        showWidgetInstructions = true
                    } label: {
                        settingsRow(title: "Add to lock screen", trailing: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
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
                                Text("· $4.99")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(StackTheme.tertiaryText)
                            })
                        }
                    }

                    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 28)

                    sectionHeader("ABOUT")
                        .padding(.top, 24)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Version 1.0")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(StackTheme.secondaryText)

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
            .navigationTitle("Settings")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showWidgetInstructions) {
                WidgetInstructionsSheet()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(store: store)
            }
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
                    .fill(StackTheme.ghost)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(StackTheme.secondaryText)
            }

            Text(text)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(StackTheme.primaryText)
        }
    }
}
