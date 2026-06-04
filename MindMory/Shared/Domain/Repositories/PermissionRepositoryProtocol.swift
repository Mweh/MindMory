protocol PermissionRepositoryProtocol {
    func notificationStatus() -> PermissionStatus
    func locationStatus() -> PermissionStatus
    func calendarStatus() -> PermissionStatus
    func requestNotificationPermission() -> PermissionStatus
    func requestLocationPermission() -> PermissionStatus
    func requestCalendarPermission() -> PermissionStatus
}
