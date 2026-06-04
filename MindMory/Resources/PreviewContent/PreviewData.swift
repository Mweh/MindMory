import Foundation

enum PreviewData {
    static let aromaMemory = Memory(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        title: "Aroma Coffee",
        subtitle: "Great conversations, the laughter, and the little moments in between.",
        dateText: "Today, 10:23 AM",
        locationName: "Aroma Coffee",
        imageName: "memory-aroma",
        journalText: "We stayed longer than planned, and that made it even better.",
        isFavorite: true,
        tags: ["Location", "Friends"]
    )

    static let holidayMemory = Memory(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        title: "Academy Lunch",
        subtitle: "A warm table, familiar voices, and a day worth keeping.",
        dateText: "Monday, May 12",
        locationName: "Apple Developer Academy",
        imageName: "memory-academy",
        journalText: nil,
        isFavorite: false,
        tags: ["Public Holiday", "Event"]
    )

    static let eveningMemory = Memory(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        title: "Evening Walk",
        subtitle: "The quiet after a full day made everything feel softer.",
        dateText: "Yesterday, 6:41 PM",
        locationName: "City Garden",
        imageName: "memory-evening",
        journalText: "Fresh air helped me remember the day clearly.",
        isFavorite: false,
        tags: ["Recent Activity"]
    )

    static let memories = [aromaMemory, holidayMemory, eveningMemory]

    static let reminder = Reminder(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
        title: "This moment looks special.",
        message: "Capture it before it’s gone.",
        context: .location(LocationContext(placeName: "Aroma Coffee", durationText: "Today, 10:23 AM")),
        imageName: "memory-aroma"
    )

    static let onboardingPages = [
        OnboardingPage(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
            imageName: "onboarding-moment",
            title: "When you’re enjoying the moment, taking a photo is easy to forget.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
            imageName: "onboarding-reminder",
            title: "MindMory gently reminds you at the right time, "
                + "with words that feel personal and smart.",
            buttonTitle: "Continue"
        ),
        OnboardingPage(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000022")!,
            imageName: "onboarding-memory",
            title: "Jot down your thoughts, see your memories, "
                + "and share them with the people who matter.",
            buttonTitle: "Continue"
        )
    ]

    static let triggerSettings = ContextTriggerSettings(
        locationBasedReminders: true,
        publicHolidayReminders: true,
        calendarReminders: true,
        userPatternReminders: false,
        recentActivityReminders: true,
        notificationWordingPreference: "Warm and thoughtful"
    )
}
