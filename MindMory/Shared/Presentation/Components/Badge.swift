import SwiftUI

enum BadgeStyle {
    case iconOnly
    case textOnly
    case iconText
}

struct Badge: View {
    let iconName: String?
    let text: String?
    let tint: Color
    let style: BadgeStyle
    let cornerRadius: CGFloat

    init(iconName: String? = nil, text: String? = nil, tint: Color = MindMoryColors.Content.primary, style: BadgeStyle = .iconOnly, cornerRadius: CGFloat = MindMoryRadius.medium) {
        self.iconName = iconName
        self.text = text
        self.tint = tint
        self.style = style
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Group {
            HStack(spacing: 6) {
                if style == .iconOnly || style == .iconText {
                    if let iconName {
                        Image(systemName: iconName)
                            .font(MindMoryTypography.labelSmall)
                            .foregroundStyle(tint)
                    }
                }

                if style == .textOnly || style == .iconText {
                    if let text {
                        Text(text)
                            .font(MindMoryTypography.labelSmall)
                            .foregroundStyle(tint)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(tint.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

#Preview {
    VStack(spacing: MindMorySpacing.sm) {
        Badge(iconName: "sparkles", text: nil, tint: MindMoryColors.Content.primary, style: .iconOnly)
        Badge(iconName: "photo.on.rectangle", text: "3 images", tint: MindMoryColors.Content.tertiary, style: .iconText)
        Badge(iconName: nil, text: "Adaptive", tint: MindMoryColors.Content.secondary, style: .textOnly)
    }
    .padding()
    .background(MindMoryColors.Surface.background)
}
