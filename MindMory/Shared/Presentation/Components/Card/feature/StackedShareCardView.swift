import SwiftUI
import UIKit

struct StackedShareCardView: View {
    let memory: Memory
    let captionText: String
    var resolvedImage: UIImage?
    var fallbackImageName: String?
    var exportMode = false

    var body: some View {
        ZStack(alignment: .center) {
            captionCard
                .frame(width: exportMode ? 470 : 250, height: exportMode ? 560 : 315)
                .rotationEffect(.degrees(-3))
                .offset(x: exportMode ? 190 : 96, y: exportMode ? 24 : 18)

            photoCard
                .frame(width: exportMode ? 520 : 285, height: exportMode ? 620 : 350)
                .offset(x: exportMode ? -118 : -58, y: exportMode ? -16 : -12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: exportMode ? 720 : 410)
    }

    private var photoCard: some View {
        VStack(alignment: .leading, spacing: exportMode ? MindMorySpacing.lg : MindMorySpacing.sm) {
            ImagePlaceholder(image: resolvedImage, imageName: fallbackImageName ?? memory.imageName)
                .frame(height: exportMode ? 410 : 230)

                Text(memory.title)
                .font(exportMode ? MindMoryTypography.titleLarge : MindMoryTypography.titleLarge)
                .foregroundStyle(MindMoryColors.Content.primary)
                .lineLimit(2)

            HStack(spacing: MindMorySpacing.sm) {
                if let locationName = memory.locationName {
                    Text(locationName)
                }
                Text(memory.dateText)
            }
            .font(MindMoryTypography.bodySmall)
            .foregroundStyle(MindMoryColors.Surface.primary)
            .lineLimit(1)
        }
        .padding(exportMode ? MindMorySpacing.xl : MindMorySpacing.md)
        .background(MindMoryColors.Content.inverse)
        .clipShape(cardShape)
        .shadow(color: MindMoryColors.Content.primary.opacity(0.16), radius: exportMode ? 30 : 20, x: 0, y: exportMode ? 20 : 14)
    }

    private var captionCard: some View {
        ZStack(alignment: .topTrailing) {
            botanicalDecoration
                .padding(exportMode ? MindMorySpacing.xl : MindMorySpacing.lg)

            VStack(alignment: .leading, spacing: exportMode ? MindMorySpacing.lg : MindMorySpacing.md) {
                Text("My Memory")
                    .font(MindMoryTypography.titleMedium)
                    .foregroundStyle(MindMoryColors.Surface.primary)

                Text(resolvedCaption)
                    .font(exportMode ? MindMoryTypography.bodyLarge : MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .lineSpacing(5)
                    .lineLimit(exportMode ? 8 : 7)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: MindMorySpacing.sm)

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    if let locationName = memory.locationName {
                        Text(locationName)
                    }
                    Text(memory.dateText)
                }
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
            }
            .padding(exportMode ? MindMorySpacing.xl : MindMorySpacing.lg)
        }
        .background(MindMoryColors.Surface.elevated)
        .clipShape(cardShape)
        .overlay { cardShape.stroke(MindMoryColors.Border.subtle.opacity(0.7), lineWidth: 1) }
        .shadow(color: MindMoryColors.Content.primary.opacity(0.10), radius: exportMode ? 24 : 16, x: 0, y: exportMode ? 18 : 12)
    }

    private var resolvedCaption: String {
        captionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? memory.subtitle : captionText
    }

    private var botanicalDecoration: some View {
        Image(systemName: "leaf.fill")
            .font(exportMode ? MindMoryTypography.titleLarge : MindMoryTypography.titleLarge)
            .foregroundStyle(MindMoryColors.Surface.primary.opacity(0.10))
            .rotationEffect(.degrees(-18))
            .allowsHitTesting(false)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
    }
}

#if DEBUG
struct StackedShareCardView_Previews: PreviewProvider {
    static var previews: some View {
        StackedShareCardView(memory: PreviewData.aromaMemory, captionText: "Caption")
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

#Preview {
    StackedShareCardView(memory: PreviewData.aromaMemory, captionText: "A short caption")
        .padding()
        .background(MindMoryColors.Surface.background)
}
