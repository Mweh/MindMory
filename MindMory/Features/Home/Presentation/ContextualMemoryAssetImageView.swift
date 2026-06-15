import Photos
import SwiftUI

struct ContextualMemoryAssetImageView: View {
    let assetLocalIdentifier: String

    @State private var image: UIImage?
    @State private var requestID: PHImageRequestID?
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ImagePlaceholder(imageName: "")

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            .task {
                requestImage(for: proxy.size, scale: displayScale)
            }
            .onDisappear {
                if let requestID {
                    PHImageManager.default().cancelImageRequest(requestID)
                }
            }
        }
    }

    private func requestImage(for size: CGSize, scale: CGFloat) {
        if let requestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }

        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier], options: nil)
        guard let asset = assets.firstObject else {
            image = nil
            return
        }

        let targetSize = CGSize(width: size.width * scale, height: min(size.height, 430) * scale)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true

        requestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            Task { @MainActor in
                image = result
            }
        }
    }
}
