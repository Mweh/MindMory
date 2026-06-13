import SwiftUI
import CoreTransferable
import ImageIO
import UniformTypeIdentifiers

struct MemoryShareImage: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { image in
            image.data
        }
        .suggestedFileName("MindMory Memory.png")
    }
}

struct ShareMemoryPreviewView: View {
    let memory: Memory
    let captionText: String
    var debugImageURL: URL? = nil
    let dismissAction: () -> Void

    @Environment(\.displayScale) private var displayScale
    @State private var shareImage: MemoryShareImage?
    @State private var renderError: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: MindMorySpacing.lg) {
                    VStack(spacing: MindMorySpacing.xs) {
                        Text("Photo + Caption + Memory")
                            .font(MindMoryTypography.headline)
                            .foregroundStyle(MindMoryColors.Content.primary)

                        Text("Your photo card and note are ready to share.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                    }
                    .multilineTextAlignment(.center)

                    StackedShareCardView(memory: memory, captionText: captionText, debugImageURL: debugImageURL)

                    if let renderError {
                        Text(renderError)
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Feedback.error)
                    }

                    shareControl
                }
                .padding(MindMorySpacing.xl)
            }
            .background(MindMoryColors.Surface.background.ignoresSafeArea())
            .navigationTitle("Share Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismissAction)
                        .foregroundStyle(MindMoryColors.Content.link)
                }
            }
        }
        .task { renderShareImage() }
    }

    @ViewBuilder
    private var shareControl: some View {
        if let shareImage {
            ShareLink(
                item: shareImage,
                preview: SharePreview(
                    "MindMory Memory",
                    image: Image(systemName: "photo.on.rectangle")
                )
            ) {
                Text("Share Memory")
                    .font(MindMoryTypography.labelLarge)
                    .foregroundStyle(MindMoryColors.Surface.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(MindMoryColors.Surface.background)
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                            .stroke(MindMoryColors.Surface.primary, lineWidth: 1)
                    }
            }
            } else {
            ProgressView("Preparing image…")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }

    @MainActor
    private func renderShareImage() {
        renderError = nil

        let renderer = ImageRenderer(
            content: ShareableMemoryExportView(
                memory: memory,
                captionText: captionText,
                debugImageURL: debugImageURL
            )
        )
        renderer.scale = displayScale

        guard let cgImage = renderer.cgImage,
              let data = pngData(from: cgImage) else {
            renderError = "Could not prepare the memory image. Please try again."
            return
        }

        shareImage = MemoryShareImage(data: data)
    }

    private func pngData(from image: CGImage) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else { return nil }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
