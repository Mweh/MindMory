import Photos
import SwiftUI

struct ContextualMemoryAssetImageView: View {
    let assetLocalIdentifier: String

    @State private var image: UIImage?
    @State private var isUnavailable = false
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
                } else if isUnavailable {
                    Text("This photo is no longer available. Please choose another memory.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                        .multilineTextAlignment(.center)
                        .padding(MindMorySpacing.lg)
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

        isUnavailable = false
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier], options: nil)
        guard let asset = assets.firstObject else {
            image = nil
            isUnavailable = true
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
        ) { result, info in
            Task { @MainActor in
                if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded, result == nil {
                    return
                }
                image = result
                isUnavailable = result == nil
            }
        }
    }
}
