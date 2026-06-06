import SwiftUI
//import EventKit

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
        //untuk check fetch calendar event
//        .task {
//            let useCase = container.makeFetchUpcomingCalendarEventsUseCase()
//            do {
//                let events = try await useCase.execute()
//                print("Calendar fetch success - \(events.count) event(s) found")
//                for event in events {
//                    let formattedDate = event.startDate.formatted(date: .abbreviated, time: .shortened)
//                    print("Event \(event.title) | \(formattedDate)")
//                }
//            } catch {
//                print("Calendar fetch failed - \(error)")
//            }
//        }
    }
}

#Preview { AppRootView() }
