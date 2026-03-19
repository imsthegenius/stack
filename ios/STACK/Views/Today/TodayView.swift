import SwiftUI

struct TodayView: View {
    let store: StackStore
    var switchToJourneyTab: (() -> Void)?
    @State private var pledgedToday: Bool = false
    @State private var showMilestoneMoment: Bool = false
    @State private var inlineRelayMessage: RelayMessage? = nil
    @State private var showInlineRelay: Bool = false
    @State private var showLockedRelay: Bool = false
    @State private var showPaywallSheet: Bool = false
    @State private var relayTask: Task<Void, Never>? = nil
    @State private var showReportConfirmation: Bool = false
    @State private var inlineRelayReported: Bool = false

    // The relay point to pass to MilestoneMomentView (for non-milestone fullscreen days)
    private var fullscreenRelayPoint: RelayPoint? {
        guard store.isFullscreenRelayDay else { return nil }
        return store.currentRelayPoint
    }

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                if let chapter = store.currentChapter {
                    Button {
                        switchToJourneyTab?()
                    } label: {
                        Text("CHAPTER \(chapter.chapterNumber)")
                            .font(.system(size: 11, weight: .light))
                            .tracking(1.5)
                            .foregroundStyle(StackTheme.tertiaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 28)
                            .padding(.top, 16)
                            .contentShape(Rectangle())
                    }
                }

                Spacer()

                counterBlock

                if pledgedToday {
                    Text("Stacked.")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 8)
                }

                // Inline relay message (free days 1-6 or paid user on inline relay day)
                if showInlineRelay, let message = inlineRelayMessage {
                    if inlineRelayReported {
                        Text("Reported. Thank you.")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .padding(.top, 16)
                            .transition(.opacity)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.text)
                                .font(Font.custom("Georgia", size: 15))
                                .foregroundStyle(StackTheme.secondaryText)
                                .lineSpacing(5)
                                .lineLimit(2)

                            Text("— someone ahead of you")
                                .font(.system(size: 11, weight: .light))
                                .foregroundStyle(StackTheme.tertiaryText)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 16)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .onLongPressGesture {
                            showReportConfirmation = true
                        }
                    }
                }

                // Locked relay state for free users on paid relay days
                if showLockedRelay {
                    VStack(spacing: 8) {
                        Text("A message is waiting.")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(StackTheme.tertiaryText)

                        Button {
                            showPaywallSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 10, weight: .light))
                                Text("Unlock STACK")
                                    .font(.system(size: 13, weight: .light))
                            }
                            .foregroundStyle(StackTheme.secondaryText)
                        }
                    }
                    .padding(.top, 16)
                    .transition(.opacity)
                }

                // Countdown to next relay (non-relay days only)
                if pledgedToday && !store.isRelayDay, let daysLeft = store.daysUntilNextRelay, daysLeft <= 7 {
                    Text("\(daysLeft) day\(daysLeft == 1 ? "" : "s") until next relay")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 12)
                }

                if store.chapters.count > 1 {
                    Text("\(store.totalDays) days total across \(store.chapters.count) chapters")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 20)
                }

                Spacer()
                Spacer().frame(height: 48)
            }
        }
        .onAppear {
            pledgedToday = store.hasPledgedToday
        }
        .onChange(of: store.hasPledgedToday) { _, newValue in
            pledgedToday = newValue
        }
        .fullScreenCover(isPresented: $showMilestoneMoment) {
            MilestoneMomentView(store: store, relayPoint: fullscreenRelayPoint)
        }
        .sheet(isPresented: $showPaywallSheet) {
            PaywallView(store: store)
        }
        .confirmationDialog("Report this message?", isPresented: $showReportConfirmation) {
            Button("Report", role: .destructive) {
                Task { await reportInlineRelay() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This message will be flagged for review and hidden from your view.")
        }
    }

    private var counterBlock: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .stroke(StackTheme.ghost, style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: pledgedToday ? 1.0 : 0.0)
                    .stroke(StackTheme.primaryText, style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 200, height: 200)
                    .animation(.easeInOut(duration: 0.6), value: pledgedToday)

                Text("\(store.currentDays)")
                    .font(.system(size: 88, weight: .thin))
                    .foregroundStyle(store.isMilestoneDay ? StackTheme.milestoneWhite : StackTheme.primaryText)
                    .contentTransition(.numericText())
            }
            .frame(width: 200, height: 200)
            .contentShape(Circle())
            .onTapGesture {
                if pledgedToday {
                    // Re-tap: open MilestoneMomentView on fullscreen relay days
                    if store.isFullscreenRelayDay || store.isMilestoneDay {
                        showMilestoneMoment = true
                    }
                    return
                }

                // Pledge
                withAnimation(.easeInOut(duration: 0.6)) { pledgedToday = true }
                store.pledgeToday()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()

                // Trigger fullscreen relay (covers milestone days + fullscreen relay days)
                if store.isFullscreenRelayDay {
                    relayTask = Task {
                        try? await Task.sleep(nanoseconds: 700_000_000)
                        guard !Task.isCancelled else { return }
                        showMilestoneMoment = true
                    }
                }

                // Trigger inline relay
                if store.isRelayDay && !store.isFullscreenRelayDay {
                    relayTask = Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        guard !Task.isCancelled else { return }
                        await showInlineRelayMessage()
                    }
                }
            }

            VStack(spacing: 6) {
                Text("DAYS")
                    .font(.system(size: 11, weight: .light))
                    .tracking(1.5)
                    .foregroundStyle(StackTheme.tertiaryText)

                if let relayPoint = store.currentRelayPoint, relayPoint.isMilestone {
                    Text(relayPoint.label.uppercased())
                        .font(.system(size: 11, weight: .light))
                        .tracking(3)
                        .foregroundStyle(StackTheme.milestoneWhite)
                } else if store.isMilestoneDay, let label = store.currentMilestoneLabel {
                    Text(label.uppercased())
                        .font(.system(size: 11, weight: .light))
                        .tracking(3)
                        .foregroundStyle(StackTheme.milestoneWhite)
                }
            }
            .padding(.top, 28)
        }
    }

    private func showInlineRelayMessage() async {
        let currentDays = store.currentDays
        guard let relayPoint = RelayPoint.relayPoint(for: currentDays) else { return }

        // Determine if user can see this message
        let canSee: Bool
        if relayPoint.isFree {
            canSee = true
        } else if store.lifetimePurchased {
            canSee = true
        } else {
            // Free user on paid inline relay day — show locked state
            withAnimation(.easeInOut(duration: 0.4)) {
                showLockedRelay = true
            }
            return
        }

        guard canSee else { return }

        // Fetch and display (skip blocked messages)
        let message = await SupabaseService.shared.fetchRelayMessage(targetDay: currentDays)
        guard let message, !store.blockedRelayMessageIDs.contains(message.id) else { return }
        inlineRelayMessage = message
        withAnimation(.easeInOut(duration: 0.4)) {
            showInlineRelay = true
        }

        // Mark as received
        if !store.receivedRelayDays.contains(currentDays) {
            store.receivedRelayDays.append(currentDays)
            store.save()
        }
    }

    private func reportInlineRelay() async {
        guard let message = inlineRelayMessage else { return }
        try? await SupabaseService.shared.reportRelayMessage(id: message.id)
        store.blockedRelayMessageIDs.append(message.id)
        store.save()
        withAnimation { inlineRelayReported = true }
    }
}
