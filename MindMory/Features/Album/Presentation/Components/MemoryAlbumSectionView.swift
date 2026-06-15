import SwiftUI
import UIKit

struct MemoryAlbumSectionView<PhotoCell: View>: View {
    let section: MemoryAlbumSection
    let isPreview: Bool
    let photoCell: (Int, MemoryAlbumSection) -> PhotoCell

    private var screenWidth: CGFloat {
        if #available(iOS 26.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                return scene.screen.bounds.width
            }
            return 390
        } else {
            return UIScreen.main.bounds.width
        }
    }

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

            GeometryReader { proxy in
                let contentWidth = max(0, proxy.size.width)
                let contentHeight = max(template.estimatedHeight(forWidth: contentWidth), template.albumHeight)

                MemoryAlbumSectionLayoutRenderer(template: template, content: { photoIndex in
                    photoCell(photoIndex, section)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }, availableWidth: contentWidth)
                .frame(width: contentWidth, height: contentHeight)
            }
            .frame(height: max(template.estimatedHeight(forWidth: screenWidth - (MindMorySpacing.xl * 2)), template.albumHeight))
            .frame(maxWidth: .infinity)

        case .text(let textSection):
            AnimatedTextSectionView(textSection: textSection, isPreview: isPreview)
                .frame(maxWidth: .infinity)
        }
    }
}
