import SwiftUI

struct MemoryCardFrontView: View {
    let memory: Memory
    var debugImageURL: URL? = nil
    let photoParallax: CGSize
    let contentParallax: CGSize

    var body: some View {
        MemoryImagePlaceholderView(imageName: memory.imageName, debugImageURL: debugImageURL)
            .offset(photoParallax)
            .frame(maxWidth: .infinity)
            .frame(height: 430)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous))
            .padding(MindMorySpacing.sm)
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
