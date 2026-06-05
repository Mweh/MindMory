protocol PermissionRepositoryProtocol {
    func notificationStatus() async -> PermissionStatus
    func locationStatus() async -> PermissionStatus
    func calendarStatus() async -> PermissionStatus
    func requestNotificationPermission() async -> PermissionStatus
    func requestLocationPermission() async -> PermissionStatus
    func requestCalendarPermission() async -> PermissionStatus
}
