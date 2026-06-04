import SwiftUI

struct ShareableMemoryFrameView: View {

    let shareableMemory: ShareableMemory

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            Text(shareableMemory.title)
                .font(MindMoryTypography.headingLarge)

            Text(shareableMemory.dateText)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)

            Text(shareableMemory.message)
                .font(MindMoryTypography.bodyLarge)
                .lineSpacing(4)

            locationLabel

            Text("MindMory")
                .font(MindMoryTypography.caption)
                .foregroundStyle(MindMoryColors.textSecondary)
        }
        .padding(MindMorySpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MindMoryColors.background)
        .clipShape(
            RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge)
        )
        .overlay {
            RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge)
                .stroke(MindMoryColors.border)
        }
        .shadow(
            color: MindMoryShadow.cardColor,
            radius: 18,
            y: 10
        )
    }

    @ViewBuilder
    private var locationLabel: some View {
        if let locationName = shareableMemory.locationName {
            Label(locationName, systemImage: "mappin.circle")
                .font(MindMoryTypography.caption)
                .foregroundStyle(MindMoryColors.primaryGreen)
        }
    }
}

#Preview {
    ShareableMemoryFrameView(
        shareableMemory: GenerateShareableMemoryUseCase().execute(
            memory: PreviewData.aromaMemory
        )
    )
    .padding()
    .background(MindMoryColors.surface)
}
