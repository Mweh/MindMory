import SwiftUI

struct AppRootView: View {
    @StateObject private var container = DependencyContainer()
    @AppStorage("hasCompletedOnboarding") private var didCompleteOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if didCompleteOnboarding {
                MainTabView(container: container, router: container.appRouter)
            } else {
                OnboardingView(viewModel: container.makeOnboardingViewModel()) { didCompleteOnboarding = true }
            }
        }
        .background(MindMoryColors.background)
        .task {
            container.configureNotificationHandling()
            if didCompleteOnboarding {
                await container.startSmartMemoryNotifications()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, didCompleteOnboarding else { return }
            Task {
                await container.startSmartMemoryNotifications()
            }
        }
        .onChange(of: didCompleteOnboarding) { _, completed in
            guard completed else { return }
            Task {
                container.configureNotificationHandling()
                await container.startSmartMemoryNotifications()
            }
        }
    }
}

#Preview { AppRootView() }
