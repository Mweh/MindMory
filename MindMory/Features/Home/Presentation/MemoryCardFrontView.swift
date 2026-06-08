import SwiftUI

struct MemoryCardFrontView: View {
    let memory: Memory
    var debugImageURL: URL? = nil
    let photoParallax: CGSize
    let contentParallax: CGSize

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            MemoryImagePlaceholderView(imageName: memory.imageName, debugImageURL: debugImageURL)
                .frame(height: 295)
                .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous))
                .offset(photoParallax)

            HStack(spacing: MindMorySpacing.sm) {
                if let locationName = memory.locationName {
                    chip(locationName, systemImage: "mappin.circle.fill")
                }
                chip(memory.dateText, systemImage: "calendar")
            }
            .offset(contentParallax)

            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text(memory.title)
                    .font(MindMoryTypography.headingLarge)
                    .foregroundStyle(MindMoryColors.textPrimary)

                Text(memory.subtitle)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.textSecondary)
                    .lineSpacing(3)
                    .lineLimit(3)
            }
            .offset(contentParallax)
        }
        .padding(MindMorySpacing.md)
        .frame(maxWidth: .infinity, minHeight: 510, alignment: .topLeading)
        .background(frontBackground)
        .clipShape(cardShape)
        .overlay { cardShape.stroke(Color.white.opacity(0.78), lineWidth: 1) }
    }

    private func chip(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(MindMoryTypography.caption)
            .foregroundStyle(MindMoryColors.primaryGreen)
            .padding(.horizontal, MindMorySpacing.sm)
            .padding(.vertical, MindMorySpacing.xs)
            .background(MindMoryColors.surface.opacity(0.92))
            .clipShape(Capsule(style: .continuous))
            .lineLimit(1)
    }

    private var frontBackground: some View {
        LinearGradient(colors: [Color.white, MindMoryColors.background, MindMoryColors.surface.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
    }
}
