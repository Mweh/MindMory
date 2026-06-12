import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
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
            .background(MindMoryColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
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
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(MindMoryColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.headerCopy.subtitle)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(MindMoryColors.primaryGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var favoriteHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("A memory from this moment.")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(MindMoryColors.primaryGreen)

            Text("Look at this picture... and tap to flip it!")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(MindMoryColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var loadingCard: some View {
        HStack(spacing: MindMorySpacing.sm) {
            ProgressView()
                .tint(MindMoryColors.primaryGreen)
            Text("Finding a memory connected to this moment…")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(MindMoryColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MindMorySpacing.md)
        .background(MindMoryColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
    }
}

#Preview { HomeView(viewModel: DependencyContainer().makeHomeViewModel()) }
