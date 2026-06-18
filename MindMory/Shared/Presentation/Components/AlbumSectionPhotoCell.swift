import SwiftUI

struct AlbumSectionPhotoCell: View {
    let image: UIImage?

    var body: some View {
        ImagePlaceholder(
            image: image,
            imageName: nil,
            placeholderStyle: image == nil ? .textOnly("Tap to add photo") : .standard
        )
        .frame(maxWidth: .infinity)
    }
}
