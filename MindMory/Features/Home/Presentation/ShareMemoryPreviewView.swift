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
                            .font(MindMoryTypography.headingLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        Text("Your photo card and note are ready to share.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textSecondary)
                    }
                    .multilineTextAlignment(.center)

                    StackedShareCardView(memory: memory, captionText: captionText)

                    if let renderError {
                        Text(renderError)
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.error)
                    }

                    shareControl
                }
                .padding(MindMorySpacing.xl)
            }
            .background(MindMoryColors.background.ignoresSafeArea())
            .navigationTitle("Share Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismissAction)
                        .foregroundStyle(MindMoryColors.primaryGreen)
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
                    .font(MindMoryTypography.button)
                    .foregroundStyle(MindMoryColors.deepGreen)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(MindMoryColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                            .stroke(MindMoryColors.primaryGreen, lineWidth: 1)
                    }
            }
        } else {
            ProgressView("Preparing image…")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.textSecondary)
        }
    }

    @MainActor
    private func renderShareImage() {
        renderError = nil

        let renderer = ImageRenderer(
            content: ShareableMemoryExportView(
                memory: memory,
                captionText: captionText
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
