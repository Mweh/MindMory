import SwiftUI

struct AppRootView: View {
    @StateObject private var container = DependencyContainer()
    @State private var isShowingSplash = true
    @AppStorage("hasCompletedOnboarding") private var didCompleteOnboarding = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Group {
                if didCompleteOnboarding {
                    NavigationStack {
                        MainTabView(container: container, router: container.appRouter)
                    }
                } else {
                    OnboardingView(viewModel: container.makeOnboardingViewModel()) { didCompleteOnboarding = true }
                }
            }
            .background(MindMoryColors.Surface.backgroundGradient.ignoresSafeArea())
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

            if isShowingSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 1_250_000_000)
                withAnimation(.easeOut(duration: 0.25)) {
                    isShowingSplash = false
                }
            }
        }
    }
}

#Preview { AppRootView() }
