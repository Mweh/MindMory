import SwiftUI
import CoreTransferable
import ImageIO
import Photos
import UniformTypeIdentifiers
import UIKit

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
    let imageSource: MemoryImageSource
    let captionText: String
    let dismissAction: () -> Void

    @Environment(\.displayScale) private var displayScale
    @State private var resolvedImage: UIImage?
    @State private var fallbackImageName: String?
    @State private var shareImage: MemoryShareImage?
    @State private var renderError: String?

    var body: some View {
        NavigationStack {
            PageLayout {
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

                    StackedShareCardView(
                        memory: memory,
                        captionText: captionText,
                        resolvedImage: resolvedImage,
                        fallbackImageName: fallbackImageName
                    )

                    if let renderError {
                        Text(renderError)
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Feedback.error)
                    }

                    shareControl
                }
            }
            .navigationTitle("Share Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismissAction)
                        .foregroundStyle(MindMoryColors.Content.link)
                }
            }
        }
        .task { await prepareShareImage() }
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
            }
            .buttonStyle(MindMoryPrimaryButtonStyle())
        } else if renderError != nil {
            PrimaryButton(title: "Share Memory", action: {})
                .disabled(true)
        } else {
            ProgressView("Preparing image…")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }

    @MainActor
    private func prepareShareImage() async {
        shareImage = nil
        renderError = nil
        resolvedImage = nil
        fallbackImageName = nil

        switch imageSource {
        case .assetLocalIdentifier(let localIdentifier):
            guard let image = await resolveAssetImage(localIdentifier: localIdentifier) else {
                renderError = "This photo is no longer available. Please choose another memory."
                return
            }
            resolvedImage = image
        case .debugImageURL(let url):
            guard let image = UIImage(contentsOfFile: url.path) else {
                renderError = "Could not prepare the memory image. Please try again."
                return
            }
            resolvedImage = image
        case .assetName(let assetName):
            fallbackImageName = assetName
        case .placeholder:
            renderError = "This photo is no longer available. Please choose another memory."
            return
        }

        renderShareImage()
    }

    @MainActor
    private func renderShareImage() {
        let renderer = ImageRenderer(
            content: ShareableMemoryExportView(
                memory: memory,
                captionText: captionText,
                resolvedImage: resolvedImage,
                fallbackImageName: fallbackImageName
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

    private func resolveAssetImage(localIdentifier: String) async -> UIImage? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = assets.firstObject else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 1080, height: 1350),
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
                    return
                }
                continuation.resume(returning: image)
            }
        }
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
