import SwiftUI

struct AlbumView: View {
    @StateObject var viewModel: AlbumViewModel
    let container: DependencyContainer
    var body: some View { NavigationStack { VStack(alignment:.leading, spacing:MindMorySpacing.lg){ header; content }.padding(MindMorySpacing.xl).background(MindMoryColors.background.ignoresSafeArea()).onAppear{viewModel.load()} } }
    private var header: some View { VStack(alignment:.leading, spacing:MindMorySpacing.sm){ Text("Album").font(MindMoryTypography.displayLarge); Text("Your memories, gathered in one calm place.").font(MindMoryTypography.bodyMedium).foregroundStyle(MindMoryColors.textSecondary); Button(action:viewModel.toggleFavoriteFilter){ Label(viewModel.showingFavoritesOnly ? "Showing Favorites" : "Show Favorites", systemImage:"star.fill").font(MindMoryTypography.bodySmall).foregroundStyle(MindMoryColors.primaryGreen) }.buttonStyle(.plain) } }
    @ViewBuilder private var content: some View { switch viewModel.state { case .loading: LoadingStateView().frame(maxWidth:.infinity); case .loaded(let memories): AlbumMemoryGridView(memories: memories, container: container); case .empty: EmptyStateView(title:"No memories yet", message:"When a moment is kept, it will appear here."); case .error(let message): ErrorStateView(message: message) } }
}
#Preview { AlbumView(viewModel: DependencyContainer().makeAlbumViewModel(), container: DependencyContainer()) }
