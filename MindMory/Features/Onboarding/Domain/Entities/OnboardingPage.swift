import Foundation

enum OnboardingPermission: Equatable {
    case location
    case calendar
    case notification

    var rawValue: String {
        switch self {
        case .location:
            return "location"
        case .calendar:
            return "calendar"
        case .notification:
            return "notification"
        }
    }

    var deniedMessage: String {
        switch self {
        case .location:
            return "Location access is still off. You can continue onboarding or enable it later in Settings."
        case .calendar:
            return "Calendar access is still off. You can continue onboarding or enable it later in Settings."
        case .notification:
            return "Notifications are still off. You can continue onboarding or enable them later in Settings."
        }
    }
}

struct OnboardingPage: Identifiable, Equatable {
    let id: UUID
    let imageName: String
    let title: String
    let permission: OnboardingPermission?
}
