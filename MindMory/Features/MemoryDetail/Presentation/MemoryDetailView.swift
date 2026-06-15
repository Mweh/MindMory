import SwiftUI

struct MemoryDetailView: View {

    @StateObject var viewModel: MemoryDetailViewModel

    var body: some View {
        PageLayout {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                heroImage
                headerSection
                subtitleSection
                journalSection
                shareButton
                shareFrameSection
            }
        }
    }

    private var heroImage: some View {
        ImagePlaceholder(imageName: viewModel.memory.imageName)
            .frame(height: 260)
            .clipShape(
                RoundedRectangle(cornerRadius: MindMoryRadius.medium)
            )
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                Text(viewModel.memory.title)
                    .font(MindMoryTypography.titleLarge)

                Text(viewModel.memory.dateText)
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)

                locationLabel
            }

            Spacer()

            favoriteButton
        }
    }

    @ViewBuilder
    private var locationLabel: some View {
        if let locationName = viewModel.memory.locationName {
            Label(locationName, systemImage: "mappin.circle")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Surface.primary)
        }
    }

    private var favoriteButton: some View {
        Button(action: viewModel.toggleFavorite) {
        Image(systemName: viewModel.memory.isFavorite ? "star.fill" : "star")
        .font(MindMoryTypography.labelLarge)
        .foregroundStyle(MindMoryColors.Surface.primary)
    }
    }

    private var subtitleSection: some View {
        Text(viewModel.memory.subtitle)
            .font(MindMoryTypography.bodyLarge)
            .foregroundStyle(MindMoryColors.Content.primary)
    }

    private var journalSection: some View {
        JournalEntryView(
            text: $viewModel.journalText,
            saveAction: viewModel.saveJournal
        )
    }

    private var shareButton: some View {
        PrimaryButton(
            title: "Share as Memory Frame",
            action: viewModel.prepareShareFrame
        )
    }

    @ViewBuilder
    private var shareFrameSection: some View {
        if let shareableMemory = viewModel.shareableMemory {
            ShareableMemoryFrameView(shareableMemory: shareableMemory)
        }
    }
}

#Preview {
    MemoryDetailView(
        viewModel: DependencyContainer().makeMemoryDetailViewModel(
            memory: PreviewData.aromaMemory
        )
    )
}
