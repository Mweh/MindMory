import UIKit

final class AlbumImageCache {
    static let shared = AlbumImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 50 * 1024 * 1024 // ~50 MB
    }

    func image(for id: UUID, data: Data) -> UIImage? {
        let key = id.uuidString as NSString
        if let image = cache.object(forKey: key) {
            return image
        }

        guard let uiImage = UIImage(data: data) else { return nil }
        cache.setObject(uiImage, forKey: key, cost: data.count)
        return uiImage
    }

    func remove(for id: UUID) {
        cache.removeObject(forKey: id.uuidString as NSString)
    }

    func clear() {
        cache.removeAllObjects()
    }
}
