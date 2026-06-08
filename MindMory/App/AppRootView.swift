import SwiftUI

struct AppRootView: View {
    @StateObject private var container = DependencyContainer()
    @State private var didCompleteOnboarding = false

    var body: some View {
        Group {
            if didCompleteOnboarding {
                MainTabView(container: container)
            } else {
                OnboardingView(viewModel: container.makeOnboardingViewModel()) { didCompleteOnboarding = true }
            }
        }
        .background(MindMoryColors.background)
    }
}

#Preview { AppRootView() }
