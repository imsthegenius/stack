import SwiftUI

struct RelayWriteView: View {
    let targetDay: Int
    let writerDay: Int
    let writePrompt: String
    let writePlaceholder: String
    let onDismiss: () -> Void

    @State private var messageText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var sentForward: Bool = false
    @State private var showError: Bool = false
    @State private var showFilterError: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let maxLength = 500

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Hidden anchor for sensory feedback on successful send
                Color.clear.frame(width: 0, height: 0)
                    .sensoryFeedback(.success, trigger: sentForward)
                HStack {
                    Spacer()
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(StackTheme.secondaryText)
                            .padding(12)
                    }
                    .accessibilityLabel("Close")
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)

                Text(writePrompt)
                    .font(StackTypography.body)
                    .foregroundStyle(StackTheme.secondaryText)
                    .padding(.horizontal, StackSpacing.horizontalPadding)
                    .padding(.top, 12)

                ZStack(alignment: .topLeading) {
                    if messageText.isEmpty {
                        Text(writePlaceholder)
                            .font(Font.custom("Georgia", size: 18))
                            .foregroundStyle(StackTheme.secondaryText)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $messageText)
                        .font(Font.custom("Georgia", size: 18))
                        .foregroundStyle(StackTheme.primaryText)
                        .tint(StackTheme.ember)
                        .scrollContentBackground(.hidden)
                        .onChange(of: messageText) { _, new in
                            if new.count > maxLength {
                                messageText = String(new.prefix(maxLength))
                            }
                        }
                }
                .padding(16)
                .background(StackTheme.surface2)
                .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadius))
                .padding(.horizontal, StackSpacing.horizontalPadding)
                .padding(.top, StackSpacing.lg)
                .frame(minHeight: 200)
                .opacity(sentForward ? 0.3 : 1.0)
                .animation(reduceMotion ? .none : .easeOut(duration: 0.3), value: sentForward)

                Text("\(maxLength - messageText.count)")
                    .font(StackTypography.caption)
                    .foregroundStyle(
                        (maxLength - messageText.count) < 50
                            ? StackTheme.ember
                            : StackTheme.secondaryText
                    )
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, StackSpacing.horizontalPadding)
                    .padding(.top, StackSpacing.sm)

                Spacer()

                Group {
                    if sentForward {
                        Text("Sent forward.")
                            .font(StackTypography.body)
                            .foregroundStyle(StackTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .transition(.opacity)
                    } else {
                        Button {
                            Task { await submit() }
                        } label: {
                            if isSubmitting {
                                ProgressView()
                                    .tint(StackTheme.background)
                            } else {
                                Text("Send forward")
                            }
                        }
                        .buttonStyle(PrimaryCTAButtonStyle())
                        .disabled(
                            isSubmitting ||
                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                        .opacity(
                            (isSubmitting || messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            ? 0.5 : 1.0
                        )
                    }
                }
                .padding(.horizontal, StackSpacing.horizontalPadding)

                if showFilterError {
                    Text("Your message couldn't be sent. Please revise it.")
                        .font(StackTypography.caption)
                        .foregroundStyle(StackTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                } else if showError {
                    Text("Something went wrong. Try again.")
                        .font(StackTypography.caption)
                        .foregroundStyle(StackTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                }

                Button {
                    onDismiss()
                } label: {
                    Text("Later")
                        .font(StackTypography.overline)
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, StackSpacing.xxl)
            }
        }
    }

    private func submit() async {
        isSubmitting = true
        showFilterError = false
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isSubmitting = false
            return
        }

        guard ContentFilter.isAcceptable(trimmed) else {
            isSubmitting = false
            showFilterError = true
            return
        }

        do {
            try await SupabaseService.shared.submitRelayMessage(text: trimmed, targetDay: targetDay, writerDay: writerDay)
            withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.4)) {
                sentForward = true
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            onDismiss()
        } catch {
            isSubmitting = false
            showError = true
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                showError = false
            }
        }
    }
}
