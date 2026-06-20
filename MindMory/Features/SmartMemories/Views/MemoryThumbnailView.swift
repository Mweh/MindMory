import SwiftUI
import Photos

public struct MemoryThumbnailView: View {
    let asset: PHAsset
    let imageManager: PHCachingImageManager
    
    @State private var image: UIImage?
    
    public init(asset: PHAsset, imageManager: PHCachingImageManager = PHCachingImageManager()) {
        self.asset = asset
        self.imageManager = imageManager
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.3)
                        .onAppear {
                            loadImage(size: geometry.size)
                        }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func loadImage(size: CGSize) {
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { result, _ in
            if let result = result {
                self.image = result
            }
        }
    }
}
