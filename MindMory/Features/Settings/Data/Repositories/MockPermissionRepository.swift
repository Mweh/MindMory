final class MockPermissionRepository: PermissionRepositoryProtocol {
    func notificationStatus() -> PermissionStatus { .notDetermined }
    func locationStatus() -> PermissionStatus { .notDetermined }
    func calendarStatus() -> PermissionStatus { .notDetermined }
    func requestNotificationPermission() -> PermissionStatus { .granted }
    func requestLocationPermission() -> PermissionStatus { .granted }
    func requestCalendarPermission() -> PermissionStatus { .granted }
}
