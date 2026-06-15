import SwiftUI

struct SectionTitle: View {
    enum Size {
        case large
        case medium
        case small
    }

    let title: String
    let description: String?
    let size: Size

    init(title: String, description: String? = nil, size: Size = .medium) {
        self.title = title
        self.description = description
        self.size = size
    }

    var body: some View {
        VStack(alignment: .leading, spacing: description == nil ? 0 : MindMorySpacing.xxs) {
            Text(title)
                .font(titleFont)
                .foregroundStyle(MindMoryColors.Content.primary)

            if let description = description {
                Text(description)
                    .font(descriptionFont)
                    .foregroundStyle(MindMoryColors.Content.secondary)
            }
        }
    }

    private var titleFont: Font {
        switch size {
        case .large:
            return MindMoryTypography.titleLarge
        case .medium:
            return MindMoryTypography.titleMedium
        case .small:
            return MindMoryTypography.titleSmall
        }
    }

    private var descriptionFont: Font {
        switch size {
        case .large:
            return MindMoryTypography.bodyLarge
        case .medium:
            return MindMoryTypography.bodyMedium
        case .small:
            return MindMoryTypography.bodySmall
        }
    }
}

#if DEBUG
struct SectionTitle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: MindMorySpacing.lg) {
            SectionTitle(
                title: "Large section title",
                description: "Large description text for a major section.",
                size: .large
            )

            SectionTitle(
                title: "Medium section title",
                description: "Medium description text for a card section.",
                size: .medium
            )

            SectionTitle(
                title: "Small section title",
                description: "Small description text for a compact section.",
                size: .small
            )

            SectionTitle(
                title: "Title only",
                description: nil,
                size: .medium
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
