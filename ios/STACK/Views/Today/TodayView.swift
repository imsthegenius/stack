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
    @State private var relayLoading: Bool = false
    @State private var counterDidAppear: Bool = false
    @State private var stackedTextVisible: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                            .font(.system(size: 12, weight: .regular))
                            .tracking(1.5)
                            .foregroundStyle(StackTheme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 28)
                            .padding(.top, 16)
                            .contentShape(Rectangle())
                    }
                }

                Spacer()

                counterBlock

                if pledgedToday && relayLoading {
                    Text("Loading relay message...")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(.top, 12)
                        .transition(.opacity)
                }

                if pledgedToday && stackedTextVisible {
                    Text("Stacked.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(.top, 20)
                        .transition(.opacity)
                }

                // Inline relay message (free days 1-6 or paid user on inline relay day)
                if showInlineRelay, let message = inlineRelayMessage {
                    if inlineRelayReported {
                        Text("Reported. Thank you.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(StackTheme.tertiaryText)
                            .padding(.top, 24)
                            .transition(.opacity)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.text)
                                .font(Font.custom("Georgia", size: 19))
                                .foregroundStyle(StackTheme.secondaryText)
                                .lineSpacing(5)

                            Text("— from \(writerLabel(for: message))")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(StackTheme.tertiaryText)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 16)
                        .transition(reduceMotion
                            ? .opacity
                            : .asymmetric(
                                insertion: .opacity.combined(with: .offset(y: 12)),
                                removal: .opacity
                            )
                        )
                        .onLongPressGesture {
                            showReportConfirmation = true
                        }
                    }
                }

                // Locked relay state for free users on paid relay days
                if showLockedRelay {
                    VStack(spacing: 8) {
                        Text("Relay message available.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(StackTheme.tertiaryText)

                        Button {
                            showPaywallSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12, weight: .regular))
                                Text("Unlock STACK")
                                    .font(.system(size: 13, weight: .regular))
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
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 12)
                }

                if store.chapters.count > 1 {
                    Text("\(store.totalDays) days total across \(store.chapters.count) chapters")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .padding(.top, 20)
                }

                Spacer()
                Spacer().frame(height: 48)
            }
        }
        .onAppear {
            pledgedToday = store.hasPledgedToday
            stackedTextVisible = store.hasPledgedToday
            // Reset inline relay state when returning to this tab (e.g. after debug day picker)
            if !pledgedToday {
                showInlineRelay = false
                inlineRelayMessage = nil
                showLockedRelay = false
                relayLoading = false
                inlineRelayReported = false
            }
            // Counter entrance animation — subtle scale + fade
            if !counterDidAppear {
                let skipMotion = reduceMotion
                Task {
                    if !skipMotion {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                    }
                    withAnimation(skipMotion ? .none : .easeOut(duration: 0.3)) {
                        counterDidAppear = true
                    }
                }
            }
            #if DEBUG
            print("[RELAY DEBUG] onAppear — currentDays=\(store.currentDays) pledgedToday=\(pledgedToday) isRelayDay=\(store.isRelayDay) isFullscreen=\(store.isFullscreenRelayDay) receivedRelayDays=\(store.receivedRelayDays)")
            #endif
            // Resume relay if user pledged but killed app before relay showed
            if pledgedToday && store.isRelayDay && !store.receivedRelayDays.contains(store.currentDays) {
                if store.isFullscreenRelayDay {
                    showMilestoneMoment = true
                } else {
                    relayLoading = true
                    Task {
                        await showInlineRelayMessage()
                        relayLoading = false
                    }
                }
            }
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
                    .animation(
                        reduceMotion ? .none : .spring(duration: 0.5, bounce: 0.15),
                        value: pledgedToday
                    )

                Text("\(store.currentDays)")
                    .font(.system(size: 88, weight: .thin))
                    .foregroundStyle(store.isMilestoneDay ? StackTheme.milestoneWhite : StackTheme.primaryText)
                    .contentTransition(.numericText())
            }
            .frame(width: 200, height: 200)
            .scaleEffect(counterDidAppear ? 1.0 : 0.97)
            .opacity(counterDidAppear ? 1.0 : 0.0)
            .contentShape(Circle())
            .accessibilityLabel(pledgedToday ? "Day \(store.currentDays), pledged" : "Day \(store.currentDays), tap to pledge")
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
                if pledgedToday {
                    // Re-tap: open MilestoneMomentView on fullscreen relay days
                    if store.isFullscreenRelayDay || store.isMilestoneDay {
                        showMilestoneMoment = true
                    }
                    return
                }

                // Pledge — use heavier haptic on milestone days
                let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = store.isMilestoneDay ? .medium : .light
                UIImpactFeedbackGenerator(style: hapticStyle).impactOccurred()

                withAnimation(reduceMotion ? .none : .spring(duration: 0.5, bounce: 0.15)) {
                    pledgedToday = true
                }
                store.pledgeToday()

                // "Stacked." delayed fade-in
                let skipMotion = reduceMotion
                Task {
                    if !skipMotion {
                        try? await Task.sleep(nanoseconds: 200_000_000)
                    }
                    withAnimation(skipMotion ? .none : .easeIn(duration: 0.25)) {
                        stackedTextVisible = true
                    }
                }

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
                    relayLoading = true
                    relayTask = Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        guard !Task.isCancelled else { return }
                        await showInlineRelayMessage()
                        relayLoading = false
                    }
                }
            }

            VStack(spacing: 6) {
                Text("DAYS")
                    .font(.system(size: 12, weight: .regular))
                    .tracking(1.5)
                    .foregroundStyle(StackTheme.secondaryText)

                if let relayPoint = store.currentRelayPoint, relayPoint.isMilestone {
                    Text(relayPoint.label.uppercased())
                        .font(.system(size: 12, weight: .regular))
                        .tracking(3)
                        .foregroundStyle(StackTheme.milestoneWhite)
                } else if store.isMilestoneDay, let label = store.currentMilestoneLabel {
                    Text(label.uppercased())
                        .font(.system(size: 12, weight: .regular))
                        .tracking(3)
                        .foregroundStyle(StackTheme.milestoneWhite)
                }
            }
            .padding(.top, 28)
        }
    }

    @MainActor
    private func showInlineRelayMessage() async {
        let currentDays = store.currentDays
        #if DEBUG
        print("[RELAY DEBUG] showInlineRelayMessage — currentDays=\(currentDays)")
        #endif
        guard let relayPoint = RelayPoint.relayPoint(for: currentDays) else {
            #if DEBUG
            print("[RELAY DEBUG] No relay point for day \(currentDays)")
            #endif
            return
        }

        // Determine if user can see this message
        let canSee: Bool
        if relayPoint.isFree {
            canSee = true
        } else if store.lifetimePurchased {
            canSee = true
        } else {
            // Free user on paid inline relay day — show locked state
            withAnimation(.easeIn(duration: 0.3)) {
                showLockedRelay = true
            }
            #if DEBUG
            print("[RELAY DEBUG] Locked — free user on paid relay day")
            #endif
            return
        }

        guard canSee else { return }

        // Fetch and display (skip blocked messages)
        #if DEBUG
        print("[RELAY DEBUG] Fetching from Supabase for day \(currentDays)...")
        #endif
        let message = await SupabaseService.shared.fetchRelayMessage(targetDay: currentDays)
        #if DEBUG
        print("[RELAY DEBUG] Fetch result: \(message?.text ?? "nil")")
        #endif
        guard let message, !store.blockedRelayMessageIDs.contains(message.id) else { return }
        inlineRelayMessage = message
        withAnimation(.spring(duration: 0.35, bounce: 0.05)) {
            showInlineRelay = true
        }

        // Mark as received
        if !store.receivedRelayDays.contains(currentDays) {
            store.receivedRelayDays.append(currentDays)
            store.save()
        }
    }

    private func writerLabel(for message: RelayMessage) -> String {
        guard let writerDay = message.writerDay else { return "ahead of you" }
        return "day \(writerDay)"
    }

    @MainActor
    private func reportInlineRelay() async {
        guard let message = inlineRelayMessage else { return }
        try? await SupabaseService.shared.reportRelayMessage(id: message.id)
        store.blockedRelayMessageIDs.append(message.id)
        store.save()
        withAnimation { inlineRelayReported = true }
    }
}
