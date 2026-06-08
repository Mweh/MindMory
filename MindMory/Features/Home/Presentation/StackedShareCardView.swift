import SwiftUI

struct StackedShareCardView: View {
    let memory: Memory
    let captionText: String
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
            MemoryImagePlaceholderView(imageName: memory.imageName)
                .frame(height: exportMode ? 410 : 230)
                .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))

            Text(memory.title)
                .font(exportMode ? MindMoryTypography.displayLarge : MindMoryTypography.headingMedium)
                .foregroundStyle(MindMoryColors.textPrimary)
                .lineLimit(2)

            HStack(spacing: MindMorySpacing.sm) {
                if let locationName = memory.locationName {
                    Text(locationName)
                }
                Text(memory.dateText)
            }
            .font(MindMoryTypography.caption)
            .foregroundStyle(MindMoryColors.primaryGreen)
            .lineLimit(1)
        }
        .padding(exportMode ? MindMorySpacing.xl : MindMorySpacing.md)
        .background(Color.white)
        .clipShape(cardShape)
        .shadow(color: .black.opacity(0.16), radius: exportMode ? 30 : 20, x: 0, y: exportMode ? 20 : 14)
    }

    private var captionCard: some View {
        ZStack(alignment: .topTrailing) {
            botanicalDecoration
                .padding(exportMode ? MindMorySpacing.xl : MindMorySpacing.lg)

            VStack(alignment: .leading, spacing: exportMode ? MindMorySpacing.lg : MindMorySpacing.md) {
                Text("My Memory")
                    .font(MindMoryTypography.headingMedium)
                    .foregroundStyle(MindMoryColors.primaryGreen)

                Text(resolvedCaption)
                    .font(exportMode ? MindMoryTypography.bodyLarge : MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.textPrimary)
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
                .font(MindMoryTypography.caption)
                .foregroundStyle(MindMoryColors.textSecondary)
            }
            .padding(exportMode ? MindMorySpacing.xl : MindMorySpacing.lg)
        }
        .background(LinearGradient(colors: [Color(hex: "#FFF7E6"), Color(hex: "#EFE6D1"), Color(hex: "#EAF1E9")], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(cardShape)
        .overlay { cardShape.stroke(MindMoryColors.border.opacity(0.7), lineWidth: 1) }
        .shadow(color: .black.opacity(0.10), radius: exportMode ? 24 : 16, x: 0, y: exportMode ? 18 : 12)
    }

    private var resolvedCaption: String {
        captionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? memory.subtitle : captionText
    }

    private var botanicalDecoration: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: exportMode ? 64 : 38))
            .foregroundStyle(MindMoryColors.primaryGreen.opacity(0.10))
            .rotationEffect(.degrees(-18))
            .allowsHitTesting(false)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
    }
}
