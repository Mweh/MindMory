import Foundation

enum SettingsAccessArea: Hashable {
    case notifications
    case location
    case calendar
}

enum ReminderSettingMode: CaseIterable, Equatable {
    case appDefault
    case customize

    var title: String {
        switch self {
        case .appDefault:
            return "App default"
        case .customize:
            return "Customize"
        }
    }

    var subtitle: String {
        switch self {
        case .appDefault:
            return "Let MindMory choose the best reminder behavior."
        case .customize:
            return "Pick your own location, calendar, and delivery preferences."
        }
    }
}

enum PointOfInterestCategory: String, CaseIterable, Identifiable {
    case parks
    case restaurants
    case stores
    case transit
    case outdoors
    case coffeeShops
    case gyms
    case libraries
    case entertainment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .parks:
            return "Parks"
        case .restaurants:
            return "Restaurants"
        case .stores:
            return "Stores"
        case .transit:
            return "Transit hubs"
        case .outdoors:
            return "Outdoor spaces"
        case .coffeeShops:
            return "Coffee shops"
        case .gyms:
            return "Gyms"
        case .libraries:
            return "Libraries"
        case .entertainment:
            return "Entertainment"
        }
    }
}

enum CalendarContextCategory: CaseIterable, Identifiable {
    case meeting
    case personal
    case travel
    case social
    case wellness

    var id: Self { self }

    var title: String {
        switch self {
        case .meeting:
            return "Meetings"
        case .personal:
            return "Personal plans"
        case .travel:
            return "Travel"
        case .social:
            return "Social events"
        case .wellness:
            return "Wellness"
        }
    }

    var description: String {
        switch self {
        case .meeting:
            return "Include scheduled meetings and work events."
        case .personal:
            return "Include personal appointments and routines."
        case .travel:
            return "Include travel and transit plans."
        case .social:
            return "Include social gatherings and meetups."
        case .wellness:
            return "Include health and wellness reminders."
        }
    }
}

enum LocationNotificationTiming: Int, CaseIterable, Identifiable {
    case arrival
    case afterShortStay

    var id: Self { self }

    var title: String {
        switch self {
        case .arrival:
            return "Notify when I arrive"
        case .afterShortStay:
            return "Notify again after a short stay"
        }
    }

    var subtitle: String {
        switch self {
        case .arrival:
            return "Trigger reminders as soon as you arrive at a selected POI."
        case .afterShortStay:
            return "Trigger reminders after you stay at a selected POI for a short while."
        }
    }
}

enum LocationVisitCooldown: CaseIterable, Identifiable {
    case fiveMinutes
    case tenMinutes
    case thirtyMinutes

    var id: Self { self }

    var title: String {
        switch self {
        case .fiveMinutes:
            return "5 minutes"
        case .tenMinutes:
            return "10 minutes"
        case .thirtyMinutes:
            return "30 minutes"
        }
    }
}

enum ScheduleLeadTime: CaseIterable, Identifiable {
    case fifteenMinutes
    case thirtyMinutes
    case oneHour

    var id: Self { self }

    var title: String {
        switch self {
        case .fifteenMinutes:
            return "15 minutes before"
        case .thirtyMinutes:
            return "30 minutes before"
        case .oneHour:
            return "1 hour before"
        }
    }
}

enum NotificationDeliveryMode: CaseIterable, Identifiable {
    case oneTime
    case repeatable

    var id: Self { self }

    var title: String {
        switch self {
        case .oneTime:
            return "One-time reminders"
        case .repeatable:
            return "Repeat reminders"
        }
    }

    var description: String {
        switch self {
        case .oneTime:
            return "Send a single reminder for each trigger."
        case .repeatable:
            return "Send reminders again until you act."
        }
    }
}

enum ReminderRepeatInterval: CaseIterable, Identifiable {
    case fourHours
    case eightHours
    case twelveHours

    var id: Self { self }

    var title: String {
        switch self {
        case .fourHours:
            return "Every 4 hours"
        case .eightHours:
            return "Every 8 hours"
        case .twelveHours:
            return "Every 12 hours"
        }
    }
}

enum DailyReminderLimit: CaseIterable, Identifiable {
    case one
    case two
    case three

    var id: Self { self }

    var title: String {
        switch self {
        case .one:
            return "1 reminder"
        case .two:
            return "2 reminders"
        case .three:
            return "3 reminders"
        }
    }
}

enum PreferredDeliveryWindow: CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening

    var id: Self { self }

    var title: String {
        switch self {
        case .morning:
            return "Morning"
        case .afternoon:
            return "Afternoon"
        case .evening:
            return "Evening"
        }
    }
}

enum ReminderSoundStyle: CaseIterable, Identifiable {
    case standard
    case gentle
    case silent

    var id: Self { self }

    var title: String {
        switch self {
        case .standard:
            return "Standard"
        case .gentle:
            return "Gentle"
        case .silent:
            return "Silent"
        }
    }
}

enum ReminderMessageTone: CaseIterable, Identifiable, Equatable {
    case warm
    case calm
    case concise

    var id: Self { self }

    var title: String {
        switch self {
        case .warm:
            return "Warm"
        case .calm:
            return "Calm"
        case .concise:
            return "Concise"
        }
    }

    var example: String {
        switch self {
        case .warm:
            return "This moment might be worth keeping."
        case .calm:
            return "A photo reminder is ready."
        case .concise:
            return "Take a photo."
        }
    }
}

struct PhotoReminderSettings {
    var reminderSettingMode: ReminderSettingMode
    var location: LocationPreferences
    var schedule: SchedulePreferences
    var delivery: DeliveryPreferences
    var message: MessagePreferences

    static let `default` = PhotoReminderSettings(
        reminderSettingMode: .appDefault,
        location: LocationPreferences(
            usesLocationContext: true,
            selectedCategories: Set(PointOfInterestCategory.allCases),
            cooldown: .tenMinutes,
            notifyOnArrival: true,
            notifyAfterShortStay: false
        ),
        schedule: SchedulePreferences(
            usesCalendarContext: true,
            selectedCategories: Set(CalendarContextCategory.allCases),
            leadTime: .thirtyMinutes,
            includesAllDayEvents: true,
            includesBusyCalendarBlocks: true
        ),
        delivery: DeliveryPreferences(
            mode: .repeatable,
            repeatInterval: .eightHours,
            dailyLimit: .two,
            preferredWindow: .afternoon,
            soundStyle: .standard,
            showsPreviewText: true,
            respectsFocusMode: true
        ),
        message: MessagePreferences(
            tone: .calm,
            includesPlaceName: true,
            includesEventTitle: true,
            explainsTriggerReason: true
        )
    )

    var locationSummary: String {
        if !location.usesLocationContext {
            return "Location reminders off"
        }

        let count = location.selectedCategories.count
        let categorySummary = count == 1 ? "1 POI category" : "\(count) POI categories"
        return "Enabled • \(categorySummary)"
    }

    var scheduleSummary: String {
        if !schedule.usesCalendarContext {
            return "Calendar reminders off"
        }

        let count = schedule.selectedCategories.count
        let categorySummary = count == 1 ? "1 calendar category" : "\(count) calendar categories"
        return "Enabled • \(categorySummary)"
    }

    var deliverySummary: String {
        switch delivery.mode {
        case .oneTime:
            return "One-time reminders"
        case .repeatable:
            return "Repeat reminders"
        }
    }
}

extension PhotoReminderSettings {
    struct LocationPreferences {
        var usesLocationContext: Bool
        var selectedCategories: Set<PointOfInterestCategory>
        var cooldown: LocationVisitCooldown
        var notifyOnArrival: Bool
        var notifyAfterShortStay: Bool
    }

    struct SchedulePreferences {
        var usesCalendarContext: Bool
        var selectedCategories: Set<CalendarContextCategory>
        var leadTime: ScheduleLeadTime
        var includesAllDayEvents: Bool
        var includesBusyCalendarBlocks: Bool
    }

    struct DeliveryPreferences {
        var mode: NotificationDeliveryMode
        var repeatInterval: ReminderRepeatInterval
        var dailyLimit: DailyReminderLimit
        var preferredWindow: PreferredDeliveryWindow
        var soundStyle: ReminderSoundStyle
        var showsPreviewText: Bool
        var respectsFocusMode: Bool
    }

    struct MessagePreferences {
        var tone: ReminderMessageTone
        var includesPlaceName: Bool
        var includesEventTitle: Bool
        var explainsTriggerReason: Bool
    }
}
