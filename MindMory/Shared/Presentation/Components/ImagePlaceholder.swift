import SwiftUI

struct ImagePlaceholder: View {
    enum PlaceholderStyle {
        case standard
        case iconOnly
        case textOnly(String)
    }

    let image: UIImage?
    let imageName: String?
    let title: String?
    let subtitle: String?
    let placeholderStyle: PlaceholderStyle
    private let cornerRadius: CGFloat = MindMoryRadius.medium

    init(
        image: UIImage? = nil,
        imageName: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        placeholderStyle: PlaceholderStyle = .standard
    ) {
        self.image = image
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.placeholderStyle = placeholderStyle
    }

    var body: some View {
        GeometryReader { proxy in
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
            .background(MindMoryColors.Surface.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(MindMoryColors.Border.subtle)
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .frame(maxWidth: .infinity)
    }

    private var placeholderContent: some View {
        ZStack {
            MindMoryColors.Surface.surface

            VStack(spacing: MindMorySpacing.sm) {
                switch placeholderStyle {
                case .standard:
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

                case .iconOnly:
                    Image(systemName: "photo")
                        .font(MindMoryTypography.titleLarge)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                case .textOnly(let text):
                    VStack(spacing: MindMorySpacing.sm) {
                        Image(systemName: "photo")
                            .font(MindMoryTypography.titleLarge)
                            .foregroundStyle(MindMoryColors.Content.secondary)

                        Text(text)
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, MindMorySpacing.md)
                    }
                }
            }
            .padding(MindMorySpacing.lg)
        }
        .frame(maxWidth: .infinity)
    }
}
