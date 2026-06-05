final class MockPermissionRepository: PermissionRepositoryProtocol {
    func notificationStatus() async -> PermissionStatus { .notDetermined }
    func locationStatus() async -> PermissionStatus { .notDetermined }
    func calendarStatus() async -> PermissionStatus { .notDetermined }
    func requestNotificationPermission() async -> PermissionStatus { .granted }
    func requestLocationPermission() async -> PermissionStatus { .granted }
    func requestCalendarPermission() async -> PermissionStatus { .granted }
}
