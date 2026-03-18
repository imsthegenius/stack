import SwiftUI

struct MilestoneMomentView: View {
    let store: StackStore
    @Environment(\.dismiss) private var dismiss

    @State private var relayMessage: RelayMessage? = nil
    @State private var isLoading: Bool = true
    @State private var showWritePhase: Bool = false
    @State private var showPaywall: Bool = false

    private var milestoneDays: Int { store.currentDays }
    private var milestoneLabel: String { store.currentMilestoneLabel ?? "" }
    private var chapterNumber: Int { store.currentChapter?.chapterNumber ?? 1 }

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("CHAPTER \(chapterNumber) · \(milestoneLabel.uppercased())")
                    .font(.system(size: 11, weight: .light))
                    .tracking(1.5)
                    .foregroundStyle(StackTheme.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.top, 16)

                Spacer()

                messageArea

                Spacer()

                Text("Take your time.")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(StackTheme.tertiaryText)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            Task { await loadRelay() }
        }
        .fullScreenCover(isPresented: $showWritePhase) {
            RelayWriteView(milestoneDays: milestoneDays, onDismiss: { dismiss() })
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(store: store)
        }
    }

    @ViewBuilder
    private var messageArea: some View {
        if isLoading {
            loadingView
        } else if store.lifetimePurchased {
            if let message = relayMessage {
                paidMessageView(message: message)
            } else {
                emptyPoolView
            }
        } else {
            freetierView
        }
    }

    private var loadingView: some View {
        Text("·  ·  ·")
            .font(.system(size: 17, weight: .light))
            .foregroundStyle(StackTheme.tertiaryText)
    }

    private func paidMessageView(message: RelayMessage) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(message.text)
                .font(Font.custom("Georgia", size: 19))
                .foregroundStyle(StackTheme.primaryText)
                .lineSpacing(9)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Written by someone at this milestone before you.")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(StackTheme.tertiaryText)
                .padding(.top, 12)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 28)
        .contentShape(Rectangle())
        .onTapGesture { showWritePhase = true }
    }

    private var emptyPoolView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("You're the first person to reach this milestone in STACK.\nWhen you write something, it'll be here for the next person.")
                .font(Font.custom("Georgia", size: 19))
                .foregroundStyle(StackTheme.primaryText)
                .lineSpacing(9)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 28)
        .contentShape(Rectangle())
        .onTapGesture { showWritePhase = true }
    }

    private var freetierView: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(relayMessage?.text ?? "Someone before you left something here. Their words are waiting for you.")
                    .font(Font.custom("Georgia", size: 19))
                    .foregroundStyle(StackTheme.primaryText)
                    .lineSpacing(9)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Written by someone at this milestone before you.")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(StackTheme.tertiaryText)
                    .padding(.top, 12)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .blur(radius: 10)

            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)

                Button {
                    showPaywall = true
                } label: {
                    Text("Unlock STACK · $4.99")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(StackTheme.background)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(StackTheme.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Text("One time. No subscription.")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(StackTheme.tertiaryText)
            }
        }
        .padding(.horizontal, 28)
    }

    private func loadRelay() async {
        isLoading = true
        if store.lifetimePurchased {
            relayMessage = await SupabaseService.shared.fetchRelayMessage(milestone: milestoneDays)
        }
        isLoading = false
        if !store.receivedRelayMilestoneDays.contains(milestoneDays) {
            store.receivedRelayMilestoneDays.append(milestoneDays)
            store.save()
        }
    }
}
