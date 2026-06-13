import Foundation
import SwiftUI

// Lightweight preview mocks to allow `SettingsViewModel()` and related in previews
private final class PreviewMockPermissionRepository: PermissionRepositoryProtocol {
    func notificationStatus() async -> PermissionStatus { .granted }
    func locationStatus() async -> PermissionStatus { .granted }
    func calendarStatus() async -> PermissionStatus { .granted }
    func requestNotificationPermission() async -> PermissionStatus { .granted }
    func requestLocationPermission() async -> PermissionStatus { .granted }
    func requestCalendarPermission() async -> PermissionStatus { .granted }
}

private final class PreviewMockQADebugSettingsRepository: QADebugSettingsRepositoryProtocol {
    var qaDebugModeEnabled: Bool = false
    var hasCompletedOnboarding: Bool = true
    var debugHomeCardImagePath: String? = nil
    var qaHomeCardState: HomeCardState = .normal
}

private final class PreviewMockContextRepository: ContextRepositoryProtocol {
    func fetchTriggerSettings() -> ContextTriggerSettings {
        ContextTriggerSettings(locationBasedReminders: true, publicHolidayReminders: false, calendarReminders: true, userPatternReminders: false, recentActivityReminders: true, notificationWordingPreference: "Warm")
    }

    func updateTriggerSettings(_ settings: ContextTriggerSettings) -> ContextTriggerSettings { settings }
}

extension SettingsViewModel {
    convenience init() {
        let repo = PreviewMockPermissionRepository()
        self.init(
            permissionRepository: repo,
            requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase(repository: repo),
            requestLocationPermissionUseCase: RequestLocationPermissionUseCase(repository: repo),
            requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase(repository: repo),
            qaDebugSettingsRepository: PreviewMockQADebugSettingsRepository(),
            debugImageStorageService: DebugImageStorageService()
        )
    }
}

extension ContextualTriggersViewModel {
    convenience init() {
        self.init(repository: PreviewMockContextRepository())
    }
}
