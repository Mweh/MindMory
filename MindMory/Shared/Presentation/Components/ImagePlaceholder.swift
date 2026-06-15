import SwiftUI

struct ImagePlaceholder: View {
    let image: UIImage?
    let imageName: String?
    let title: String?
    let subtitle: String?
    let cornerRadius: CGFloat?
    let useBackground: Bool

    init(
        image: UIImage? = nil,
        imageName: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        cornerRadius: CGFloat? = MindMoryRadius.medium,
        useBackground: Bool = true
    ) {
        self.image = image
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.cornerRadius = cornerRadius
        self.useBackground = useBackground
    }

    var body: some View {
        let content = GeometryReader { proxy in
            Group {
                if let image = image {
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

        Group {
            if let cornerRadius {
                content
                    .background(useBackground ? MindMoryColors.Surface.surface : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            } else {
                content
                    .background(useBackground ? MindMoryColors.Surface.surface : Color.clear)
            }
        }
    }

    private var placeholderContent: some View {
        ZStack {
            if useBackground {
                MindMoryColors.Surface.surface
            }

            VStack(spacing: MindMorySpacing.sm) {
                Image(systemName: "photo")
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                    .padding(MindMorySpacing.lg)
                    .background(
                        Circle()
                            .fill(MindMoryColors.Surface.background)
                    )
                    .padding(MindMorySpacing.sm)

                if let title {
                    Text(title)
                        .font(MindMoryTypography.titleMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, MindMorySpacing.md)
                }

                if let subtitle {
                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, MindMorySpacing.md)
                }
            }
            .padding(MindMorySpacing.lg)
        }
        .frame(maxWidth: .infinity)
    }
}
