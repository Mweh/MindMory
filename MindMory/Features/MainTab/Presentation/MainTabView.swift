import SwiftUI

enum MainTab: CaseIterable {
    case home, album, settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .album: return "Album"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .album: return "photo.on.rectangle"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    let container: DependencyContainer
    @State private var selectedTab: MainTab = .home
    var body: some View {
        ZStack(alignment: .bottom) {
            Group { switch selectedTab { case .home: HomeView(viewModel: container.makeHomeViewModel()); case .album: AlbumView(viewModel: container.makeAlbumViewModel(), container: container); case .settings: SettingsView(viewModel: container.makeSettingsViewModel(), triggersViewModel: container.makeContextualTriggersViewModel()) } }
                .padding(.bottom, 82)
            MainTabBarView(selectedTab: $selectedTab)
        }
        .background(MindMoryColors.background.ignoresSafeArea())
    }
}
#Preview { MainTabView(container: DependencyContainer()) }
