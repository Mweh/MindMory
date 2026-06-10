import SwiftUI

struct MemoryAlbumSectionView<PhotoCell: View>: View {
    let section: MemoryAlbumSection
    let isPreview: Bool
    let photoCell: (Int, MemoryAlbumSection) -> PhotoCell

    init(
        section: MemoryAlbumSection,
        isPreview: Bool = false,
        @ViewBuilder photoCell: @escaping (Int, MemoryAlbumSection) -> PhotoCell
    ) {
        self.section = section
        self.isPreview = isPreview
        self.photoCell = photoCell
    }

    var body: some View {
        switch section.content {
        case .image(let layoutCount, let layoutVariant, _):
            let template = MemoryAlbumSectionLayoutCatalog.template(layoutCount: layoutCount, variant: layoutVariant)

            MemoryAlbumSectionLayoutRenderer(template: template) { photoIndex in
                photoCell(photoIndex, section)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: template.albumHeight)

        case .text(let textSection):
            AnimatedTextSectionView(textSection: textSection, isPreview: isPreview)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
