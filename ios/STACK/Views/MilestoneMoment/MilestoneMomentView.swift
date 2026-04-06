import SwiftUI

struct MilestoneMomentView: View {
    let store: StackStore
    let relayPoint: RelayPoint?
    @Environment(\.dismiss) private var dismiss

    @State private var relayMessage: RelayMessage? = nil
    @State private var isLoading: Bool = true
    @State private var showWritePhase: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showReportConfirmation: Bool = false
    @State private var reportedMessage: Bool = false
    @State private var headerVisible: Bool = false
    @State private var messageVisible: Bool = false
    @State private var footerVisible: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var targetDay: Int {
        relayPoint?.day ?? store.currentDays
    }

    private var milestoneWriterLabel: String {
        guard let writerDay = relayMessage?.writerDay else { return "ahead of you" }
        return "day \(writerDay)"
    }

    private var headerLabel: String {
        relayPoint?.label.uppercased() ?? store.currentMilestoneLabel?.uppercased() ?? ""
    }

    private var chapterNumber: Int {
        store.currentChapter?.chapterNumber ?? 1
    }

    // Write-forward mapping: find the relay point this writer should write for
    private var writeTarget: RelayPoint? {
        RelayPoint.allRelayPoints.first { $0.writerDay == store.currentDays }
    }

    private var writeTargetDay: Int {
        writeTarget?.day ?? targetDay
    }

    private var writePromptText: String {
        writeTarget?.writePrompt ?? "Now write something for the next person who stands here."
    }

    private var writePlaceholderText: String {
        writeTarget?.writePlaceholder ?? "What do you wish someone had told you?"
    }

    init(store: StackStore, relayPoint: RelayPoint? = nil) {
        self.store = store
        self.relayPoint = relayPoint
    }

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("CHAPTER \(chapterNumber) · \(headerLabel)")
                    .font(StackTypography.overline)
                    .tracking(1.5)
                    .foregroundStyle(StackTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                    .opacity(headerVisible ? 1.0 : 0.0)

                Spacer()

                messageArea
                    .opacity(messageVisible ? 1.0 : 0.0)
                    .offset(y: messageVisible ? 0 : (reduceMotion ? 0 : 10))

                Spacer()

                Text("Take your time.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.white)
                    .padding(.bottom, 48)
                    .opacity(footerVisible ? 1.0 : 0.0)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(StackTheme.secondaryText)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Close")
                    .padding(.trailing, 8)
                    .padding(.top, 8)
                }
                Spacer()
            }
        }
        .onAppear {
            // Staggered entrance: header first
            withAnimation(reduceMotion ? .none : .easeOut(duration: 0.3)) {
                headerVisible = true
            }
            Task { await loadRelay() }
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                if isLoading { isLoading = false }
            }
        }
        .onChange(of: isLoading) { _, loading in
            if !loading {
                if relayMessage != nil {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                // Message animates in when fetch completes
                withAnimation(reduceMotion ? .none : StackAnimation.cardEntrance) {
                    messageVisible = true
                }
                // Footer fades in 500ms after message
                let skipMotion = reduceMotion
                Task {
                    if !skipMotion {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                    }
                    withAnimation(skipMotion ? .none : .easeOut(duration: 0.3)) {
                        footerVisible = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showWritePhase) {
            RelayWriteView(
                targetDay: writeTargetDay,
                writerDay: store.currentDays,
                writePrompt: writePromptText,
                writePlaceholder: writePlaceholderText,
                onDismiss: { dismiss() }
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(store: store)
        }
    }

    private var canSeeMessage: Bool {
        store.lifetimePurchased || (relayPoint?.isFree == true)
    }

    @ViewBuilder
    private var messageArea: some View {
        if isLoading {
            loadingView
        } else if canSeeMessage {
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
        RelayCard {
            VStack(alignment: .leading, spacing: 12) {
                SkeletonView(height: 16)
                SkeletonView(width: 220, height: 16)
                SkeletonView(width: 160, height: 12)
            }
        }
        .padding(.horizontal, 28)
    }

    private func paidMessageView(message: RelayMessage) -> some View {
        VStack(spacing: 0) {
            RelayCard(padding: 24) {
                VStack(alignment: .leading, spacing: 0) {
                    if reportedMessage {
                        Text("Reported. Thank you.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(StackTheme.secondaryText)
                    } else {
                        Text(message.text)
                            .font(Font.custom("Georgia", size: 19))
                            .foregroundStyle(StackTheme.primaryText)
                            .lineSpacing(9)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Text("— from \(milestoneWriterLabel)")
                                .font(StackTypography.footnote)
                                .foregroundStyle(StackTheme.secondaryText)

                            Spacer()

                            Button {
                                showReportConfirmation = true
                            } label: {
                                Image(systemName: "flag")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(StackTheme.secondaryText)
                            }
                            .accessibilityLabel("Report message")
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .padding(.horizontal, 28)

            if !reportedMessage {
                HStack(spacing: 4) {
                    Text("Write one for the next person")
                        .font(.system(size: 13, weight: .regular))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .regular))
                }
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 14)
            }
        }
        .contentShape(Rectangle())
        .accessibilityLabel("Write a relay message forward")
        .accessibilityAddTraits(.isButton)
        .onTapGesture { if !reportedMessage { showWritePhase = true } }
        .confirmationDialog("Report this message?", isPresented: $showReportConfirmation) {
            Button("Report", role: .destructive) {
                Task { await reportMessage(message) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This message will be flagged for review and hidden from your view.")
        }
    }

    private var emptyPoolView: some View {
        RelayCard(padding: 24) {
            Text("You're the first to reach \(headerLabel) in STACK.\nWhen you write something, it'll be here for the next person.")
                .font(Font.custom("Georgia", size: 19))
                .foregroundStyle(StackTheme.primaryText)
                .lineSpacing(9)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 28)
        .contentShape(Rectangle())
        .accessibilityLabel("Write a relay message")
        .accessibilityAddTraits(.isButton)
        .onTapGesture { showWritePhase = true }
    }

    private var freetierView: some View {
        VStack(spacing: 0) {
            RelayCard(padding: 24) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(truncatedText)
                        .font(Font.custom("Georgia", size: 19))
                        .foregroundStyle(StackTheme.secondaryText)
                        .lineSpacing(9)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("— from \(milestoneWriterLabel)")
                        .font(StackTypography.footnote)
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(.top, 12)
                }
            }
            .padding(.horizontal, 28)

            Button {
                showPaywall = true
            } label: {
                Text("Unlock")
            }
            .buttonStyle(PrimaryCTAButtonStyle())
            .padding(.horizontal, 28)
            .padding(.top, 20)

            Text("One time. No subscription.")
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
        }
    }

    private var truncatedText: String {
        guard let text = relayMessage?.text else {
            return "A message from ahead of you."
        }
        let words = text.split(separator: " ")
        if words.count <= 15 {
            return text
        }
        return words.prefix(15).joined(separator: " ") + "..."
    }

    private func loadRelay() async {
        isLoading = true
        // Always fetch — free tier shows truncated, paid shows full
        if let msg = await SupabaseService.shared.fetchRelayMessage(targetDay: targetDay) {
            // Skip blocked messages
            if !store.blockedRelayMessageIDs.contains(msg.id) {
                relayMessage = msg
            }
        }
        isLoading = false
        if !store.receivedRelayDays.contains(targetDay) {
            store.receivedRelayDays.append(targetDay)
            store.save()
        }
    }

    private func reportMessage(_ message: RelayMessage) async {
        try? await SupabaseService.shared.reportRelayMessage(id: message.id)
        store.blockedRelayMessageIDs.append(message.id)
        store.save()
        withAnimation(reduceMotion ? .none : .default) { reportedMessage = true }
    }
}
