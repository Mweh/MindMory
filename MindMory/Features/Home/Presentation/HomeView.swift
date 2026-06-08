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
                        InteractiveMemoryCardView(
                            memory: memory,
                            side: $viewModel.cardSide,
                            captionText: $viewModel.captionText,
                            flipAction: viewModel.flipCard,
                            shareAction: viewModel.showSharePreview
                        )
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
                    dismissAction: viewModel.dismissSharePreview
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text("You’re in the middle of \(viewModel.eventName).")
                .font(MindMoryTypography.displayLarge)
                .foregroundStyle(MindMoryColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Capture it before it’s gone.")
                .font(MindMoryTypography.headingMedium)
                .foregroundStyle(MindMoryColors.primaryGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview { HomeView(viewModel: DependencyContainer().makeHomeViewModel()) }
