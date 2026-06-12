import Photos
import SwiftUI

struct ContextualMemoryAssetImageView: View {
    let assetLocalIdentifier: String

    @State private var image: UIImage?
    @State private var requestID: PHImageRequestID?

    var body: some View {
        ZStack {
            MemoryImagePlaceholderView(imageName: "")

            if let image {
                GeometryReader { proxy in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
            }
        }
        .task(id: assetLocalIdentifier) {
            requestImage()
        }
        .onDisappear {
            if let requestID {
                PHImageManager.default().cancelImageRequest(requestID)
            }
        }
    }

    private func requestImage() {
        if let requestID {
            PHImageManager.default().cancelImageRequest(requestID)
        }

        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier], options: nil)
        guard let asset = assets.firstObject else {
            image = nil
            return
        }

        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: UIScreen.main.bounds.width * scale, height: 430 * scale)
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
