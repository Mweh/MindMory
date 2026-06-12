import SwiftUI

struct AppRootView: View {
    @StateObject private var container = DependencyContainer()
    @AppStorage("hasCompletedOnboarding") private var didCompleteOnboarding = false

    var body: some View {
        Group {
            if didCompleteOnboarding {
                NavigationStack {
                    MainTabView(container: container)
                }
            } else {
                OnboardingView(viewModel: container.makeOnboardingViewModel()) { didCompleteOnboarding = true }
            }
        }
        .background(MindMoryColors.background)
    }
}

#Preview { AppRootView() }
