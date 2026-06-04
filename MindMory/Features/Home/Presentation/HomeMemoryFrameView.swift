import SwiftUI

struct HomeMemoryFrameView: View {

    let memory: Memory
    var compact = false

    var body: some View {
        AppCard {
            HStack(alignment: .top, spacing: MindMorySpacing.md) {
                textSection

                Spacer()

                thumbnailView
            }
        }
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            if let locationName = memory.locationName {
                Label(locationName, systemImage: "mappin.circle")
                    .font(MindMoryTypography.caption)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }

            Text(memory.dateText)
                .font(MindMoryTypography.caption)
                .foregroundStyle(MindMoryColors.textSecondary)

            Text(memory.subtitle)
                .font(compact ? MindMoryTypography.bodySmall : MindMoryTypography.bodyLarge)
                .foregroundStyle(MindMoryColors.textPrimary)
                .lineSpacing(3)
        }
    }

    private var thumbnailView: some View {
        MemoryImagePlaceholderView(imageName: memory.imageName)
            .frame(
                width: compact ? 72 : 104,
                height: compact ? 72 : 104
            )
            .clipShape(
                RoundedRectangle(cornerRadius: MindMoryRadius.medium)
            )
    }
}
