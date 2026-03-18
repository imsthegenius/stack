import SwiftUI

struct StackCardView: View {
    let store: StackStore
    let milestoneDays: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet: Bool = false
    @State private var shareImage: UIImage?

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
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(StackTheme.secondaryText)
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)

                Spacer()

                stackCircle
                    .frame(width: 128, height: 128)

                Text(milestoneLabel.uppercased())
                    .font(.system(size: 22, weight: .light))
                    .tracking(2)
                    .foregroundStyle(StackTheme.primaryText)
                    .padding(.top, 28)

                Text("One at a time.")
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(StackTheme.secondaryText)
                    .padding(.top, 12)

                if let info = store.earnedDate(for: milestoneDays) {
                    VStack(spacing: 4) {
                        Text("Since \(StackDateFormatter.string(from: info.chapter.startDate))")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(StackTheme.tertiaryText)

                        Text("CHAPTER \(info.chapter.chapterNumber)")
                            .font(.system(size: 11, weight: .light))
                            .tracking(1.5)
                            .foregroundStyle(StackTheme.tertiaryText)
                    }
                    .padding(.top, 24)
                }

                Spacer()

                Button {
                    renderAndShare()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                        Text("Share")
                            .font(.system(size: 14, weight: .light))
                    }
                    .foregroundStyle(StackTheme.secondaryText)
                }
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image, "\(milestoneLabel). One at a time. — STACK"])
            }
        }
    }

    private var stackCircle: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "C8A96E"), lineWidth: 1.5)

            Text(Milestone.shortLabel(for: milestoneDays))
                .font(.system(size: 54, weight: .thin))
                .foregroundStyle(Color(hex: "C8A96E"))
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
                    .stroke(Color(hex: "C8A96E"), lineWidth: 1.5)
                    .frame(width: 128, height: 128)

                Text(Milestone.shortLabel(for: milestoneDays))
                    .font(.system(size: 54, weight: .thin))
                    .foregroundStyle(Color(hex: "C8A96E"))
            }

            Text((Milestone.label(for: milestoneDays) ?? "").uppercased())
                .font(.system(size: 22, weight: .light))
                .tracking(2)
                .foregroundStyle(Color(hex: "F4F2EE"))
                .padding(.top, 28)

            Text("One at a time.")
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Color(hex: "8C8880"))
                .padding(.top, 12)

            Spacer()

            Text("STACK")
                .font(.system(size: 11, weight: .light))
                .tracking(2)
                .foregroundStyle(Color(hex: "4A4845"))
                .padding(.bottom, 24)
        }
        .frame(width: 390, height: 500)
        .background(Color(hex: "0C0B09"))
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
