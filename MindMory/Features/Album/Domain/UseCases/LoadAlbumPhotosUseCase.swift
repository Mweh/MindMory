import Foundation
import UIKit

struct LoadAlbumPhotosUseCase {
    func execute(from items: [Data]) async -> [AlbumPhoto] {
        var loadedPhotos: [AlbumPhoto] = []

        for data in items {
            if Task.isCancelled {
                break
            }

            if let uiImage = UIImage(data: data) {
                let imageData = uiImage.jpegData(compressionQuality: 0.8) ?? data
                loadedPhotos.append(AlbumPhoto(id: UUID(), imageData: imageData))
            }
        }

        return loadedPhotos
    }
}
