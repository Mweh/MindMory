import SwiftUI

struct AppRootView: View {
    @ObservedObject var container: DependencyContainer
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
            .environmentObject(container)
            .background(MindMoryColors.Surface.backgroundGradient.ignoresSafeArea())
            .task {
                container.configureNotificationHandling()
                if didCompleteOnboarding {
                    await container.syncCalendarNotifications()
                    await container.startDistanceReminders()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active, didCompleteOnboarding else { return }
                Task {
                    await container.syncCalendarNotifications()
                    await container.startDistanceReminders()
                }
            }
            .onChange(of: didCompleteOnboarding) { _, completed in
                guard completed else { return }
                Task {
                    container.configureNotificationHandling()
                    await container.syncCalendarNotifications()
                    await container.startDistanceReminders()
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

    private func hideSplashScreen() async {
        try? await Task.sleep(nanoseconds: 900_000_000)
        await MainActor.run {
            isShowingSplash = false
        }
    }
}

#Preview { AppRootView(container: DependencyContainer()) }
