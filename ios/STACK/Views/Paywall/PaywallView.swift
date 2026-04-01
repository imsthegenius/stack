import SwiftUI
import RevenueCat

struct PaywallView: View {
    let store: StackStore
    @Environment(\.dismiss) private var dismiss

    @State private var offering: Offering?
    @State private var isLoadingOffering: Bool = true
    @State private var loadFailed: Bool = false
    @State private var isPurchasing: Bool = false
    @State private var isRestoring: Bool = false
    @State private var errorMessage: String?

    private var priceString: String {
        offering?.lifetime?.storeProduct.localizedPriceString ?? ""
    }

    private var buttonDisabled: Bool {
        isLoadingOffering || isPurchasing || isRestoring || offering == nil
    }

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .padding(12)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    Text("The relay.")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(StackTheme.primaryText)

                    Text("Anonymous messages from people who reached the same milestones. Read theirs. Leave one for the next person.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(StackTheme.secondaryText)
                        .lineSpacing(4)
                        .padding(.top, 16)

                    if !priceString.isEmpty {
                        Text("\(priceString) · one time · forever")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .padding(.top, 24)
                    }
                }
                .padding(.horizontal, 28)

                Spacer()

                VStack(spacing: 0) {
                    Button {
                        if loadFailed {
                            Task { await loadOffering() }
                        } else {
                            Task { await purchase() }
                        }
                    } label: {
                        Group {
                            if isLoadingOffering {
                                ProgressView()
                                    .tint(StackTheme.background)
                            } else if isPurchasing {
                                ProgressView()
                                    .tint(StackTheme.background)
                            } else if loadFailed {
                                Text("Retry")
                            } else {
                                Text("Unlock STACK")
                            }
                        }
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(StackTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(StackTheme.primaryText)
                        .clipShape(.rect(cornerRadius: 12))
                        .opacity(buttonDisabled && !loadFailed ? 0.4 : 1.0)
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .disabled(buttonDisabled && !loadFailed)

                    Button {
                        Task { await restore() }
                    } label: {
                        Group {
                            if isRestoring {
                                ProgressView()
                                    .tint(StackTheme.tertiaryText)
                                    .scaleEffect(0.75)
                            } else {
                                Text("Restore purchases")
                            }
                        }
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.vertical, 12)
                    }
                    .disabled(isPurchasing || isRestoring)
                    .padding(.top, 16)

                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .padding(.top, 8)
                    }

                    HStack(spacing: 16) {
                        Link("Terms of Use", destination: URL(string: "https://stack.twohundred.ai/terms.html")!)
                            .underline()
                        Link("Privacy Policy", destination: URL(string: "https://stack.twohundred.ai/privacy.html")!)
                            .underline()
                    }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(StackTheme.tertiaryText)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
        .task {
            await loadOffering()
        }
    }

    private func loadOffering() async {
        isLoadingOffering = true
        loadFailed = false
        do {
            let offerings = try await Purchases.shared.offerings()
            offering = offerings.current
            if offering?.lifetime == nil {
                loadFailed = true
                errorMessage = "Could not load purchase. Tap to retry."
            }
        } catch {
            loadFailed = true
            errorMessage = "Could not load purchase. Tap to retry."
        }
        isLoadingOffering = false
    }

    private func purchase() async {
        guard let package = offering?.lifetime else { return }
        isPurchasing = true
        errorMessage = nil

        do {
            let (_, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            if !userCancelled {
                sync(customerInfo)
                dismiss()
            }
        } catch {
            errorMessage = "Something went wrong. Try again."
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                errorMessage = nil
            }
        }
        isPurchasing = false
    }

    private func restore() async {
        isRestoring = true
        errorMessage = nil

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            sync(customerInfo)
            if customerInfo.entitlements["Stack Forever"]?.isActive == true {
                dismiss()
            }
        } catch {
            errorMessage = "Restore failed. Try again."
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                errorMessage = nil
            }
        }
        isRestoring = false
    }

    private func sync(_ customerInfo: CustomerInfo) {
        let active = customerInfo.entitlements["Stack Forever"]?.isActive == true
        store.lifetimePurchased = active
        store.save()
    }
}
