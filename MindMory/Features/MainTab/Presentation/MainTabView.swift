import SwiftUI

enum MainTab: CaseIterable {
    case home
    case album
    case settings

    var title: String {
        switch self {
        case .home:
            return "Home"

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

    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: container.makeHomeViewModel())
                .tabItem {
                    Label(
                        MainTab.home.title,
                        systemImage: MainTab.home.icon
                    )
                }
                .tag(MainTab.home)

            AlbumListView(viewModel: container.makeAlbumListViewModel())
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
    }
}

#Preview {
    MainTabView(container: DependencyContainer())
}
