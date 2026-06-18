import UIKit

extension AlbumPhoto {
    var uiImage: UIImage? {
        AlbumImageCache.shared.image(for: id, data: imageData)
    }

    static func from(urlString: String) -> AlbumPhoto? {
        guard let url = URL(string: urlString) else { return nil }

        #if DEBUG
        // Allow synchronous loading for Xcode previews only
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            if let data = try? Data(contentsOf: url), !data.isEmpty {
                return AlbumPhoto(id: UUID(), imageData: data)
            }
        }
        #endif

        return nil
    }

    static func loadAsync(from urlString: String) async -> AlbumPhoto? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard !data.isEmpty else { return nil }
            return AlbumPhoto(id: UUID(), imageData: data)
        } catch {
            return nil
        }
    }
}
