import Foundation

enum OnboardingPageCatalog {
    static let pages = [
        OnboardingPage(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
            imageName: "onboarding_1",
            title: "If \"I forgot to take photos again\" sounds familiar, you're in the right app.",
            permission: nil
        ),
        OnboardingPage(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
            imageName: "onboarding_2",
            title: "No matter where you are, MindMory adapts its reminders to match",
            permission: .location
        ),
        OnboardingPage(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000022")!,
            imageName: "onboarding_3",
            title: "Your calendar already knows what's happening. We make plans memorable",
            permission: .calendar
        ),
        OnboardingPage(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000023")!,
            imageName: "onboarding_4",
            title: "Just enable notifications—we’ll take care of the reminders.",
            permission: .notification
        )
    ]
}
