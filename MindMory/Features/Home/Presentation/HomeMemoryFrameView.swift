import SwiftUI

struct HomeMemoryFrameView: View {

    let memory: Memory
    var compact = false

    var body: some View {
        HStack(alignment: .top, spacing: MindMorySpacing.md) {
            textSection

            Spacer()

            thumbnailView
        }
        .padding(MindMorySpacing.lg)
        .mindMoryCardStyle()
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            if let locationName = memory.locationName {
                Label(locationName, systemImage: "mappin.circle")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
            }

            Text(memory.dateText)
                .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)

            Text(memory.subtitle)
                .font(compact ? MindMoryTypography.bodySmall : MindMoryTypography.bodyLarge)
                .foregroundStyle(MindMoryColors.Content.primary)
                .lineSpacing(3)
        }
    }

    private var thumbnailView: some View {
        Group {
            switch memory.imageSource {
            case .assetLocalIdentifier(let id):
                ContextualMemoryAssetImageView(assetLocalIdentifier: id)
            case .assetName(let name):
                Image(name)
                    .resizable()
                    .scaledToFill()
            case .debugImageURL(let url):
                if #available(iOS 15.0, *) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ImagePlaceholder(imageName: nil)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            ImagePlaceholder(imageName: nil)
                        @unknown default:
                            ImagePlaceholder(imageName: nil)
                        }
                    }
                } else {
                    ImagePlaceholder(imageName: nil)
                }
            case .placeholder:
                ImagePlaceholder(imageName: nil)
            }
        }
        .frame(
            width: compact ? 72 : 104,
            height: compact ? 72 : 104
        )
        .clipShape(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium)
        )
    }
}
