import SwiftUI
import UIKit

struct MemoryCardFrontView: View {
    let memory: Memory
    var imageSource: MemoryImageSource
    let photoParallax: CGSize
    let contentParallax: CGSize

    var body: some View {
        imageContent
            .offset(photoParallax)
            .frame(maxWidth: .infinity)
            .frame(height: 430)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            .padding(MindMorySpacing.sm)
            .background(frontBackground)
            .clipShape(cardShape)
            .overlay { cardShape.stroke(Color.white.opacity(0.78), lineWidth: 1) }
    }

    @ViewBuilder
    private var imageContent: some View {
        switch imageSource {
        case .assetLocalIdentifier(let localIdentifier):
            ContextualMemoryAssetImageView(assetLocalIdentifier: localIdentifier)
        case .assetName(let assetName):
            ImagePlaceholder(imageName: assetName)
        case .debugImageURL(let url):
            if let image = UIImage(contentsOfFile: url.path) {
                ImagePlaceholder(image: image)
            } else {
                ImagePlaceholder(imageName: nil)
            }
        case .placeholder:
            ImagePlaceholder(imageName: nil)
        }
    }

    private func chip(_ title: String, systemImage: String) -> some View {
        FilterChip(title: title, systemImage: systemImage, isSelected: false) {}
            .font(MindMoryTypography.bodySmall)
            .foregroundStyle(MindMoryColors.Surface.primary)
            .lineLimit(1)
            .padding(.vertical, 0)
    }

    private var frontBackground: some View {
        MindMoryColors.Surface.elevated
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
    }
}

#if DEBUG
struct MemoryCardFrontView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryCardFrontView(memory: PreviewData.aromaMemory, imageSource: PreviewData.aromaMemory.imageSource, photoParallax: .zero, contentParallax: .zero)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

#Preview {
    MemoryCardFrontView(memory: PreviewData.aromaMemory, imageSource: PreviewData.aromaMemory.imageSource, photoParallax: .zero, contentParallax: .zero)
        .padding()
        .background(MindMoryColors.Surface.background)
}
