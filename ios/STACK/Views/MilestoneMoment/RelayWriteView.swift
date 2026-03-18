import SwiftUI

struct RelayWriteView: View {
    let milestoneDays: Int
    let onDismiss: () -> Void

    @State private var messageText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var sentForward: Bool = false
    @Environment(\.dismiss) private var dismiss

    private let maxLength = 500

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("Now write something for the next person who stands here.")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)
                    .padding(.horizontal, 28)
                    .padding(.top, 48)

                ZStack(alignment: .topLeading) {
                    if messageText.isEmpty {
                        Text("What do you wish someone had told you?")
                            .font(Font.custom("Georgia", size: 18))
                            .foregroundStyle(StackTheme.ghost)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $messageText)
                        .font(Font.custom("Georgia", size: 18))
                        .foregroundStyle(StackTheme.primaryText)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .onChange(of: messageText) { _, new in
                            if new.count > maxLength {
                                messageText = String(new.prefix(maxLength))
                            }
                        }
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .frame(minHeight: 160)

                if maxLength - messageText.count < 100 {
                    Text("\(maxLength - messageText.count)")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 28)
                        .padding(.top, 8)
                }

                Spacer()

                Button {
                    Task { await submit() }
                } label: {
                    Group {
                        if sentForward {
                            Text("Sent forward.")
                        } else if isSubmitting {
                            ProgressView()
                                .tint(StackTheme.primaryText)
                        } else {
                            Text("Send forward")
                        }
                    }
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "1C1B19"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(
                    isSubmitting ||
                    messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    sentForward
                )
                .padding(.horizontal, 28)

                Button {
                    onDismiss()
                } label: {
                    Text("Later")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(StackTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.bottom, 48)
            }
        }
    }

    private func submit() async {
        isSubmitting = true
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isSubmitting = false
            return
        }

        do {
            try await SupabaseService.shared.submitRelayMessage(text: trimmed, milestone: milestoneDays)
            withAnimation(.easeInOut(duration: 0.4)) {
                sentForward = true
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            onDismiss()
        } catch {
            // Silent failure — don't show error to user
            isSubmitting = false
        }
    }
}
