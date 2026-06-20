import Foundation
import Photos

public protocol PhotoLibraryService {
    func requestAuthorization() async -> Bool
    func fetchAssets() async -> [PHAsset]
}

public final class DefaultPhotoLibraryService: PhotoLibraryService {
    public init() {}
    
    public func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status == .authorized || status == .limited
    }
    
    public func fetchAssets() async -> [PHAsset] {
        return await Task.detached {
            let options = PHFetchOptions()
            // Most recent first
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            
            let fetchResult = PHAsset.fetchAssets(with: options)
            var assets: [PHAsset] = []
            
            fetchResult.enumerateObjects { asset, _, _ in
                // Exclude screenshots
                if !asset.mediaSubtypes.contains(.photoScreenshot) {
                    assets.append(asset)
                }
            }
            return assets
        }.value
    }
}
