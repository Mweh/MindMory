import UIKit

extension AlbumPhoto {
    var uiImage: UIImage? {
        UIImage(data: imageData)
    }

    static func from(urlString: String) -> AlbumPhoto? {
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              !data.isEmpty else {
            return nil
        }

        return AlbumPhoto(id: UUID(), imageData: data)
    }
}
