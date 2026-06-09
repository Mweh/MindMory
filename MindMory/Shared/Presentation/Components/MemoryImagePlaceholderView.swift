import ImageIO
import SwiftUI

private struct LoadedDebugImage {
    let cgImage: CGImage
    let orientation: Image.Orientation
}

struct MemoryImagePlaceholderView: View {

    let imageName: String
    var debugImageURL: URL? = nil

    var body: some View {
        if let debugImageURL,
           let debugImage = loadDebugImage(from: debugImageURL) {
            GeometryReader { proxy in
                Image(
                    decorative: debugImage.cgImage,
                    scale: 1,
                    orientation: debugImage.orientation
                )
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }
        } else {
            placeholderContent
        }
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
        ZStack(alignment: .bottomLeading) {
            backgroundGradient
            decorativeContent
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                MindMoryColors.surfaceStrong,
                MindMoryColors.surface,
                MindMoryColors.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var decorativeContent: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            overlappingCircles

            Image(systemName: "leaf.fill")
                .foregroundStyle(MindMoryColors.primaryGreen.opacity(0.55))
        }
        .padding(MindMorySpacing.md)
    }

    private var overlappingCircles: some View {
        HStack(spacing: -8) {
            Circle()
                .fill(MindMoryColors.primaryGreen.opacity(0.85))
                .frame(width: 44, height: 44)

            Circle()
                .fill(MindMoryColors.mutedIndigo.opacity(0.45))
                .frame(width: 44, height: 44)

            Circle()
                .fill(MindMoryColors.primaryGreen.opacity(0.55))
                .frame(width: 44, height: 44)
        }
    }
}
