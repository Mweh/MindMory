import Combine
import SwiftUI


enum MainTab: CaseIterable {
    case home
    case album
    case settings

    var title: String {
        switch self {
        case .home:
            return "Memories"

        case .album:
            return "Album"

        case .settings:
            return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"

        case .album:
            return "photo.on.rectangle"

        case .settings:
            return "gearshape"
        }
    }
}

struct MainTabView: View {

    let container: DependencyContainer
    @ObservedObject var router: AppRouter
    @StateObject private var homeViewModel: HomeViewModel

    init(container: DependencyContainer, router: AppRouter) {
        self.container = container
        self.router = router
        _homeViewModel = StateObject(wrappedValue: container.makeHomeViewModel())
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label(
                        MainTab.home.title,
                        systemImage: MainTab.home.icon
                    )
                }
                .tag(MainTab.home)

            AlbumView(viewModel: container.makeAlbumListViewModel())
                .tabItem {
                    Label(
                        MainTab.album.title,
                        systemImage: MainTab.album.icon
                    )
                }
                .tag(MainTab.album)

            SettingsView(
                viewModel: container.makeSettingsViewModel()
            )
            .tabItem {
                Label(
                    MainTab.settings.title,
                    systemImage: MainTab.settings.icon
                )
            }
            .tag(MainTab.settings)
        }
        .tint(MindMoryColors.primaryGreen)
        .background(MindMoryColors.background)
        .onReceive(router.$routedAssetLocalIdentifier.compactMap { $0 }) { assetLocalIdentifier in
            homeViewModel.showContextualAsset(localIdentifier: assetLocalIdentifier)
            _ = router.consumeRoutedAssetLocalIdentifier()
        }
    }
}

#Preview {
    let container = DependencyContainer()
    MainTabView(container: container, router: container.appRouter)
}
