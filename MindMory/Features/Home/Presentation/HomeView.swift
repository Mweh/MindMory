import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @AppStorage("hasSeenTooltip") private var hasSeenTooltip = false
    @State private var cardFrame: CGRect = .zero

    var body: some View {
        PageLayout(
            padding: EdgeInsets(
                top: MindMorySpacing.xl,
                leading: MindMorySpacing.xl,
                bottom: MindMorySpacing.xxl,
                trailing: MindMorySpacing.xl
            )
        ) {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                header

                HomeStatsGridView(
                    cards: viewModel.statCards,
                    selectedStat: viewModel.selectedStat,
                    selectAction: viewModel.selectStat
                )

                contextualContent
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear { viewModel.load() }
        .onPreferenceChange(CardFrameKey.self) { frame in
            cardFrame = frame
        }
        .overlay {
            if !hasSeenTooltip && cardFrame != .zero && viewModel.cardSide == .front {
                SpotlightTooltipView(cardFrame: cardFrame) {
                    hasSeenTooltip = true
                }
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $viewModel.isShowingSharePreview) {
            if let memory = viewModel.focusedMemory {
                ShareMemoryPreviewView(
                    memory: memory,
                    imageSource: viewModel.focusedImageSource,
                    captionText: viewModel.captionText,
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
            NoPermissionStateView(
                title: "Photos access is required",
                subtitle: "Allow photo access so MindMory can surface memories from nearby moments.",
                buttonTitle: "Allow Access",
                iconName: "photo.on.rectangle.angled",
                action: viewModel.didTapAllowPhotoAccess
            )
        case .permissionRequired:
            NoPermissionStateView(
                title: "Permission needed",
                subtitle: "Allow access so MindMory can connect your current location with meaningful memories.",
                buttonTitle: "Allow Access",
                iconName: "location.fill",
                action: viewModel.didTapAllowPhotoAccess
            )
        case .empty:
            ContextualMemoryEmptyStateView(
                title: "This might be your first memory here.",
                subtitle: "We’ll help you keep this moment when it becomes worth remembering."
            )
        case .error:
            if let errorMessage = viewModel.contextualErrorMessage {
                ErrorStateView(
                    message: errorMessage,
                    retryAction: viewModel.retryContextualDiscovery
                )
            } else {
                ErrorStateView(message: "Something went wrong.", retryAction: viewModel.retryContextualDiscovery)
            }
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
                imageSource: viewModel.focusedImageSource,
                side: $viewModel.cardSide,
                captionText: $viewModel.captionText,
                flipAction: viewModel.flipCard,
                shareAction: viewModel.showSharePreview
            )
            .overlay(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: CardFrameKey.self,
                        value: geo.frame(in: .global)
                    )
                }
            )
        case .firstReminderPrepared:
            FirstReminderPreparedCardView()
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
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
    }
}

#Preview { HomeView(viewModel: DependencyContainer().makeHomeViewModel()) }
