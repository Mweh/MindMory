import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                header

                HomeStatsGridView(
                    cards: viewModel.statCards,
                    selectedStat: viewModel.selectedStat,
                    selectAction: viewModel.selectStat
                )

                contextualContent
            }
            .padding(.horizontal, MindMorySpacing.xl)
            .padding(.top, MindMorySpacing.xl)
            .padding(.bottom, MindMorySpacing.xxl)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(MindMoryColors.Surface.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear { viewModel.load() }
        .sheet(isPresented: $viewModel.isShowingSharePreview) {
            if let memory = viewModel.focusedMemory {
                ShareMemoryPreviewView(
                    memory: memory,
                    captionText: viewModel.captionText,
                    debugImageURL: viewModel.debugHomeCardImageURL,
                    dismissAction: viewModel.dismissSharePreview
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private var contextualContent: some View {
        switch viewModel.contextualState {
        case .loading:
            loadingCard
            if let memory = viewModel.focusedMemory {
                favoriteHeader
                homeCard(for: memory)
            }
        case .permissionRequired(.photoLibrary):
            PhotoAccessDeniedCardView(
                allowAction: viewModel.didTapAllowPhotoAccess
            )
        case .permissionRequired:
            ContextualMemoryEmptyStateView(
                title: "Memories can meet you where you are.",
                subtitle: "Allow access when you’re ready to rediscover nearby moments.",
                systemImage: "location.fill"
            )
        case .empty, .error:
            ContextualMemoryEmptyStateView(
                title: "This might be your first memory here.",
                subtitle: "We’ll help you keep this moment when it becomes worth remembering."
            )
        case .loaded, .idle:
            if let memory = viewModel.focusedMemory {
                favoriteHeader
                homeCard(for: memory)
            } else {
                ContextualMemoryEmptyStateView(
                    title: "This might be your first memory here.",
                    subtitle: "We’ll help you keep this moment when it becomes worth remembering."
                )
            }
        }
    }

    @ViewBuilder
    private func homeCard(for memory: Memory) -> some View {
        switch viewModel.homeCardState {
        case .normal:
            InteractiveMemoryCardView(
                memory: memory,
                assetLocalIdentifier: viewModel.contextualAssetLocalIdentifier,
                debugImageURL: viewModel.debugHomeCardImageURL,
                side: $viewModel.cardSide,
                captionText: $viewModel.captionText,
                flipAction: viewModel.flipCard,
                shareAction: viewModel.showSharePreview
            )
        case .firstReminderPrepared:
            FirstReminderPreparedCardView()
        case .photoAccessDenied:
            PhotoAccessDeniedCardView(
                allowAction: viewModel.didTapAllowPhotoAccess
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text(viewModel.headerCopy.title)
                .font(MindMoryTypography.headline)
                .foregroundStyle(MindMoryColors.Content.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.headerCopy.subtitle)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.link)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var favoriteHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("A memory from this moment.")
                .font(MindMoryTypography.titleMedium)
                .foregroundStyle(MindMoryColors.Content.link)

            Text("Look at this picture... and tap to flip it!")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var loadingCard: some View {
        HStack(spacing: MindMorySpacing.sm) {
            ProgressView()
                .tint(MindMoryColors.Surface.primary)
            Text("Finding a memory connected to this moment…")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MindMorySpacing.md)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
    }
}

#Preview { HomeView(viewModel: DependencyContainer().makeHomeViewModel()) }
