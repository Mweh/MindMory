import SwiftUI
import UIKit

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

            // Compute a stable container width based on the active window scene's screen when possible.
            let screenWidth: CGFloat = {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    return scene.screen.bounds.width
                }
                return UIScreen.main.bounds.width
            }()

            let containerWidth = max(0, screenWidth - (MindMorySpacing.xl * 2))
            let estimatedHeight = template.estimatedHeight(forWidth: containerWidth)

            MemoryAlbumSectionLayoutRenderer(template: template, content: { photoIndex in
                photoCell(photoIndex, section)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }, availableWidth: containerWidth)
            .frame(maxWidth: .infinity)
            .frame(height: max(estimatedHeight, template.albumHeight))

        case .text(let textSection):
            AnimatedTextSectionView(textSection: textSection, isPreview: isPreview)
                .frame(maxWidth: .infinity)
        }
    }
}
