import Foundation

struct Reminder: Identifiable, Equatable {
    let id: UUID
    let title: String
    let message: String
    let context: ReminderContext
    let imageName: String?
}

enum ReminderContext: Equatable {
    case location(LocationContext)
    case publicHoliday(HolidayContext)
    case event(EventContext)
    case locationAndHoliday(LocationContext, HolidayContext)
    case none
}

struct LocationContext: Equatable {
    let placeName: String
    let durationText: String
}

struct HolidayContext: Equatable {
    let name: String
    let dateText: String
}

struct EventContext: Equatable {
    let title: String
    let timeText: String
}
