import SwiftUI

struct AlbumSectionPhotoCell: View {
    let image: UIImage?

    var body: some View {
        MemoryImagePlaceholderView(
            image: image,
            imageName: nil,
            placeholderIcon: "photo.on.rectangle",
            placeholderText: image == nil ? "Tap to add photo" : nil
        )
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .stroke(MindMoryColors.Border.subtle)
        )
        .contentShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        .frame(maxWidth: .infinity)
    }
}
