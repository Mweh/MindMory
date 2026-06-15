import SwiftUI

struct AlbumSectionPhotoCell: View {
    let image: UIImage?

    var body: some View {
        ImagePlaceholder(
            image: image,
            imageName: nil,
            subtitle: image == nil ? "Tap to add photo" : nil,
            useBackground: false
        )
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .stroke(MindMoryColors.Border.subtle)
        )
        .contentShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        .frame(maxWidth: .infinity)
    }
}
