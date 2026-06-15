import SwiftUI

struct ShareableMemoryFrameView: View {

    let shareableMemory: ShareableMemory

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            Text(shareableMemory.title)
                .font(MindMoryTypography.titleMedium)

            Text(shareableMemory.dateText)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)

            Text(shareableMemory.message)
                .font(MindMoryTypography.bodyLarge)
                .lineSpacing(4)

            locationLabel

            Text("MindMory")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
        .padding(MindMorySpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MindMoryColors.Surface.background)
        .clipShape(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium)
        )
        .overlay {
            RoundedRectangle(cornerRadius: MindMoryRadius.medium)
                .stroke(MindMoryColors.Border.subtle)
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
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.link)
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
    .background(MindMoryColors.Surface.surface)
}
