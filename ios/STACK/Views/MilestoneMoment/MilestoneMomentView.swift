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

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .padding(12)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                Spacer()
            }
        }
        .onAppear {
            Task { await loadRelay() }
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                if isLoading { isLoading = false }
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
        Text("·  ·  ·")
            .font(.system(size: 17, weight: .light))
            .foregroundStyle(StackTheme.tertiaryText)
            .opacity(0.3)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isLoading)
    }

    private func paidMessageView(message: RelayMessage) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if reportedMessage {
                    Text("Reported. Thank you.")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                } else {
                    Text(message.text)
                        .font(Font.custom("Georgia", size: 19))
                        .foregroundStyle(StackTheme.primaryText)
                        .lineSpacing(9)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Text("— from \(milestoneWriterLabel)")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(StackTheme.tertiaryText)

                        Spacer()

                        Button {
                            showReportConfirmation = true
                        } label: {
                            Image(systemName: "flag")
                                .font(.system(size: 11, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        }
                    }
                    .padding(.top, 12)
                }
            }
            .padding(24)
            .background(StackTheme.separator)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 28)

            if !reportedMessage {
                Text("Tap to write one forward →")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(StackTheme.tertiaryText)
                    .padding(.top, 12)
            }
        }
        .contentShape(Rectangle())
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
        VStack(alignment: .leading, spacing: 0) {
            Text("You're the first to reach \(headerLabel) in STACK.\nWhen you write something, it'll be here for the next person.")
                .font(Font.custom("Georgia", size: 19))
                .foregroundStyle(StackTheme.primaryText)
                .lineSpacing(9)
        }
        .padding(24)
        .background(StackTheme.separator)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 28)
        .contentShape(Rectangle())
        .onTapGesture { showWritePhase = true }
    }

    private var freetierView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Show truncated real message or fallback
            Text(truncatedText)
                .font(Font.custom("Georgia", size: 19))
                .foregroundStyle(StackTheme.tertiaryText)
                .lineSpacing(9)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("— from \(milestoneWriterLabel)")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(StackTheme.tertiaryText)
                .padding(.top, 12)

            // Unlock button
            Button {
                showPaywall = true
            } label: {
                Text("Unlock STACK")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(StackTheme.primaryText)
                    .clipShape(.rect(cornerRadius: 10))
            }
            .padding(.top, 20)

            Text("One time. No subscription.")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(StackTheme.tertiaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
        }
        .padding(24)
        .background(StackTheme.separator)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 28)
    }

    private var truncatedText: String {
        guard let text = relayMessage?.text else {
            return "Someone before you left something here..."
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
        withAnimation { reportedMessage = true }
    }
}
