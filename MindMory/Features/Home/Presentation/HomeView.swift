import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    var body: some View {
        NavigationStack { HomeStateView(state: viewModel.state).navigationBarHidden(true) }
            .onAppear { viewModel.load() }
    }
}
#Preview { HomeView(viewModel: DependencyContainer().makeHomeViewModel()) }
