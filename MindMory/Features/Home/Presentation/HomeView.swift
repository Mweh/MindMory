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

                    if let memory = viewModel.focusedMemory {
                        favoriteHeader
                        homeCard(for: memory)
                    }
                }
                .padding(.horizontal, MindMorySpacing.xl)
                .padding(.top, MindMorySpacing.xl)
                .padding(.bottom, MindMorySpacing.xxl)
            }
            .background(MindMoryColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
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
    private func homeCard(for memory: Memory) -> some View {
        switch viewModel.homeCardState {
        case .normal:
            InteractiveMemoryCardView(
                memory: memory,
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
            Text("You’re in the middle of \(viewModel.eventName).")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(MindMoryColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Capture it before it’s gone.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(MindMoryColors.primaryGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var favoriteHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("One of your favorites.")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(MindMoryColors.primaryGreen)

            Text("Look at this picture... and tap to flip it!")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(MindMoryColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview { HomeView(viewModel: DependencyContainer().makeHomeViewModel()) }
