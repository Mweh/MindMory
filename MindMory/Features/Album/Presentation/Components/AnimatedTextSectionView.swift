import SwiftUI

typealias MemoryAlbumTextSectionRenderView = AnimatedTextSectionView

struct AnimatedTextSectionView: View {
    let textSection: MemoryAlbumTextSection
    var isPreview: Bool = false
    var delay: Double = 0

    var body: some View {
        VStack(alignment: stackHorizontalAlignment, spacing: MindMorySpacing.xs) {
            if textSection.blockType == .titleAndDescription {
                if textSection.isTitleFirst {
                    titleView
                    descriptionView
                } else {
                    descriptionView
                    titleView
                }
            } else if textSection.blockType == .titleOnly {
                titleView
            } else {
                descriptionView
            }
        }
        .frame(maxWidth: .infinity, alignment: combinedAlignment)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var titleView: some View {
        Text(textSection.title)
            .font(MindMoryTypography.titleLarge)
            .foregroundStyle(MindMoryColors.Content.primary)
            .multilineTextAlignment(multilineAlignment)
            .frame(maxWidth: .infinity, alignment: frameHorizontalAlignment)
            .lineLimit(isPreview ? 2 : nil)
    }

    private var descriptionView: some View {
        Text(textSection.description)
            .font(MindMoryTypography.bodyMedium)
            .foregroundStyle(MindMoryColors.Content.secondary)
            .multilineTextAlignment(multilineAlignment)
            .frame(maxWidth: .infinity, alignment: frameHorizontalAlignment)
            .lineLimit(isPreview ? 3 : nil)
    }

    private var combinedAlignment: Alignment {
        switch (textSection.verticalAlignment, textSection.horizontalAlignment) {
        case (.top, .leading):
            return .topLeading
        case (.top, .center):
            return .top
        case (.top, .trailing):
            return .topTrailing
        case (.center, .leading):
            return .leading
        case (.center, .center):
            return .center
        case (.center, .trailing):
            return .trailing
        case (.bottom, .leading):
            return .bottomLeading
        case (.bottom, .center):
            return .bottom
        case (.bottom, .trailing):
            return .bottomTrailing
        }
    }

    private var frameHorizontalAlignment: Alignment {
        switch textSection.horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }

    private var stackHorizontalAlignment: HorizontalAlignment {
        switch textSection.horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }

    private var multilineAlignment: TextAlignment {
        switch textSection.horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}

private extension MemoryAlbumTextWeight {
    var fontWeight: Font.Weight {
        switch self {
        case .regular:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        }
    }
}
