import SwiftUI

struct StackCardView: View {
    let store: StackStore
    let milestoneDays: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet: Bool = false
    @State private var shareImage: UIImage?
    @State private var showRelay: Bool = false

    private var milestoneLabel: String {
        Milestone.label(for: milestoneDays) ?? ""
    }

    var body: some View {
        ZStack {
            StackTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StackTheme.secondaryText)
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)

                Spacer()

                stackCircle
                    .frame(width: 128, height: 128)

                Text(milestoneLabel.uppercased())
                    .font(StackTypography.subhead)
                    .tracking(2)
                    .foregroundStyle(.white)
                    .padding(.top, 28)

                Text("One at a time.")
                    .font(StackTypography.callout)
                    .foregroundStyle(StackTheme.secondaryText)
                    .padding(.top, 12)

                if let info = store.earnedDate(for: milestoneDays) {
                    VStack(spacing: 4) {
                        Text("Since \(StackDateFormatter.string(from: info.chapter.startDate))")
                            .font(StackTypography.caption)
                            .foregroundStyle(StackTheme.secondaryText)

                        Text("CHAPTER \(info.chapter.chapterNumber)")
                            .font(StackTypography.caption)
                            .tracking(1.5)
                            .foregroundStyle(StackTheme.secondaryText)
                    }
                    .padding(.top, 24)
                }

                Spacer()

                VStack(spacing: 16) {
                    if RelayPoint.relayPoint(for: milestoneDays) != nil {
                        Button {
                            showRelay = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "envelope")
                                    .font(.system(size: 14, weight: .regular))
                                Text("Read the relay")
                                    .font(StackTypography.footnote)
                            }
                            .foregroundStyle(StackTheme.primaryText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(StackTheme.surface2)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(StackTheme.ghost, lineWidth: 1.0))
                        }
                    }

                    Button {
                        renderAndShare()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .regular))
                            Text("Share")
                                .font(StackTypography.footnote)
                        }
                        .foregroundStyle(StackTheme.secondaryText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(StackTheme.surface2)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(StackTheme.ghost, lineWidth: 1.0))
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image, "\(milestoneLabel). One at a time. — STACK"])
            }
        }
        .fullScreenCover(isPresented: $showRelay) {
            MilestoneMomentView(store: store, relayPoint: RelayPoint.relayPoint(for: milestoneDays))
        }
    }

    private var stackCircle: some View {
        ZStack {
            Circle()
                .stroke(StackTheme.ember, lineWidth: 2)

            Text(Milestone.shortLabel(for: milestoneDays))
                .font(.system(size: 54, weight: .regular))
                .foregroundStyle(.white)
        }
    }

    private func renderAndShare() {
        let exportView = StackExportView(milestoneDays: milestoneDays, store: store)
        let renderer = ImageRenderer(content: exportView)
        renderer.scale = 3
        if let image = renderer.uiImage {
            shareImage = image
            showShareSheet = true
        }
    }
}

// Clean export view — no app chrome, used only for ImageRenderer
struct StackExportView: View {
    let milestoneDays: Int
    let store: StackStore

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(StackTheme.ember, lineWidth: 2)
                    .frame(width: 128, height: 128)

                Text(Milestone.shortLabel(for: milestoneDays))
                    .font(.system(size: 54, weight: .regular))
                    .foregroundStyle(.white)
            }

            Text((Milestone.label(for: milestoneDays) ?? "").uppercased())
                .font(StackTypography.subhead)
                .tracking(2)
                .foregroundStyle(.white)
                .padding(.top, 28)

            Text("One at a time.")
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.top, 12)

            Spacer()

            Text("STACK")
                .font(StackTypography.overline)
                .tracking(2)
                .foregroundStyle(StackTheme.secondaryText)
                .padding(.bottom, 24)
        }
        .frame(width: 390, height: 500)
        .background(StackTheme.background)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
