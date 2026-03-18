import SwiftUI
import StoreKit

struct PaywallView: View {
    let store: StackStore
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing: Bool = false

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Not now") { dismiss() }
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(StackTheme.secondaryText)
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)

                HStack(spacing: 48) {
                    ForEach(0..<3, id: \.self) { _ in
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 48, height: 48)
                    }
                }
                .padding(.top, 48)

                Text("Everything you've earned.")
                    .font(.system(size: 34, weight: .thin))
                    .foregroundStyle(StackTheme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                    .padding(.horizontal, 28)

                VStack(spacing: 12) {
                    paywallFeature("Every Stack. Yours to keep.")
                    paywallFeature("The Relay — hear from those who've been here.")
                    paywallFeature("Lock screen widget. Your count, always.")
                }
                .padding(.top, 28)

                Spacer()

                Button {
                    // TODO: StoreKit purchase (com.stack.app.lifetime)
                    Task { await purchaseLifetime() }
                } label: {
                    Text("Unlock · $4.99")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(StackTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(StackTheme.primaryText)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .disabled(isPurchasing)
                .padding(.horizontal, 28)

                Text("One time. No subscription.")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(StackTheme.tertiaryText)
                    .padding(.top, 8)

                Button {
                    // TODO: StoreKit restore purchases
                    Task { await restorePurchases() }
                } label: {
                    Text("Restore purchases")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                }
                .padding(.top, 16)
                .padding(.bottom, 48)
            }
        }
    }

    private func paywallFeature(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .light))
            .foregroundStyle(StackTheme.secondaryText)
    }

    private func purchaseLifetime() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let products = try await Product.products(for: ["com.stack.app.lifetime"])
            guard let product = products.first else { return }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    store.lifetimePurchased = true
                    store.save()
                    dismiss()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            // Purchase failed silently
        }
    }

    private func restorePurchases() async {
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   transaction.productID == "com.stack.app.lifetime" {
                    store.lifetimePurchased = true
                    store.save()
                    dismiss()
                    return
                }
            }
        } catch {
            // Restore failed silently
        }
    }
}
