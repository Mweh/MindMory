import SwiftUI
import PhotosUI

struct AlbumCoverCardView: View {
    @ObservedObject var viewModel: MemoryAlbumCreationViewModel
    @Binding var selectedCoverPhotoItem: PhotosPickerItem?

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Cover photo")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.primary)

                PhotosPicker(
                    selection: $selectedCoverPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    MemoryImagePlaceholderView(
                        image: viewModel.coverPhoto?.uiImage,
                        imageName: nil,
                        placeholderIcon: "photo.on.rectangle",
                        placeholderText: viewModel.coverPhoto.map { _ in "Tap to change cover photo" } ?? "Tap to add cover photo"
                    )
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                            .stroke(MindMoryColors.Border.subtle)
                    )
                }
            }
        }
    }
}

#if DEBUG
struct AlbumCoverCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumCoverCardView(viewModel: MemoryAlbumCreationViewModel(), selectedCoverPhotoItem: .constant(nil))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
