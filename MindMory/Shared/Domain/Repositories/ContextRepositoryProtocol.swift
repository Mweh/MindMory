struct ContextTriggerSettings: Equatable {
    var locationBasedReminders: Bool
    var publicHolidayReminders: Bool
    var calendarReminders: Bool
    var userPatternReminders: Bool
    var recentActivityReminders: Bool
    var notificationWordingPreference: String
}

protocol ContextRepositoryProtocol {
    func fetchTriggerSettings() -> ContextTriggerSettings
    func updateTriggerSettings(_ settings: ContextTriggerSettings) -> ContextTriggerSettings
}
