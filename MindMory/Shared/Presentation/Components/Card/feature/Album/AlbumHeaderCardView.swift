import SwiftUI

struct AlbumHeaderCardView: View {
    let name: String
    let coverPhoto: UIImage?
    let albumDateText: String
    let photoCountText: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                Text(name)
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)

                if let image = coverPhoto {
                    MemoryImagePlaceholderView(image: image, imageName: nil)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                } else {
                    MemoryImagePlaceholderView(image: nil, imageName: nil)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                                .stroke(MindMoryColors.Border.subtle)
                        )
                }

                HStack(spacing: MindMorySpacing.md) {
                    Text(albumDateText)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                    Spacer()

                    Text(photoCountText)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.link)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#if DEBUG
struct AlbumHeaderCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumHeaderCardView(name: "Vacation", coverPhoto: nil, albumDateText: "June 2026", photoCountText: "12 photos")
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
