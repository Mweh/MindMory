import SwiftUI
import PhotosUI

struct AlbumDetailsFormCardView: View {
    @ObservedObject var viewModel: MemoryAlbumCreationViewModel
    @Binding var selectedCoverPhotoItem: PhotosPickerItem?

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Memory title")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.primary)

                TextField("Enter memory title", text: $viewModel.albumName)
                    .font(MindMoryTypography.bodyMedium)
                    .padding(MindMorySpacing.md)
                    .background(MindMoryColors.Surface.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                            .stroke(MindMoryColors.Border.subtle)
                    )
            }
        }
    }
}

#if DEBUG
struct AlbumDetailsFormCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDetailsFormCardView(viewModel: MemoryAlbumCreationViewModel(), selectedCoverPhotoItem: .constant(nil))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
