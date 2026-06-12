import ImageIO
import SwiftUI

private struct LoadedDebugImage {
    let cgImage: CGImage
    let orientation: Image.Orientation
}

struct MemoryImagePlaceholderView: View {
    let image: UIImage?
    let imageName: String?
    var debugImageURL: URL? = nil
    let placeholderIcon: String
    let placeholderText: String?

    init(
        image: UIImage? = nil,
        imageName: String? = nil,
        debugImageURL: URL? = nil,
        placeholderIcon: String = "photo",
        placeholderText: String? = nil
    ) {
        self.image = image
        self.imageName = imageName
        self.debugImageURL = debugImageURL
        self.placeholderIcon = placeholderIcon
        self.placeholderText = placeholderText
    }

    var body: some View {
        GeometryReader { proxy in
            Group {
                if let debugImageURL,
                   let debugImage = loadDebugImage(from: debugImageURL) {
                    Image(
                        decorative: debugImage.cgImage,
                        scale: 1,
                        orientation: debugImage.orientation
                    )
                    .resizable()
                    .scaledToFill()
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let imageName = imageName, !imageName.isEmpty {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholderContent
                }
            }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
            .frame(maxWidth: .infinity)
    }

    private func loadDebugImage(from url: URL) -> LoadedDebugImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        return LoadedDebugImage(
            cgImage: cgImage,
            orientation: imageOrientation(from: source)
        )
    }

    private func imageOrientation(from source: CGImageSource) -> Image.Orientation {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let rawOrientation = properties[kCGImagePropertyOrientation] as? UInt32 else {
            return .up
        }

        switch rawOrientation {
        case 1:
            return .up
        case 2:
            return .upMirrored
        case 3:
            return .down
        case 4:
            return .downMirrored
        case 5:
            return .leftMirrored
        case 6:
            return .right
        case 7:
            return .rightMirrored
        case 8:
            return .left
        default:
            return .up
        }
    }

    private var placeholderContent: some View {
        ZStack {
            MindMoryColors.placeholderSurface

            VStack(spacing: MindMorySpacing.sm) {
                Image(systemName: placeholderIcon)
                    .font(.title)
                    .foregroundStyle(MindMoryColors.mutedIndigo)

                if let placeholderText = placeholderText {
                    Text(placeholderText)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.mutedIndigo)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, MindMorySpacing.md)
                }
            }
            .padding(MindMorySpacing.lg)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
    }
}
