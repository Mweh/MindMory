import UIKit

extension AlbumPhoto {
    var uiImage: UIImage? {
        UIImage(data: imageData)
    }
}
