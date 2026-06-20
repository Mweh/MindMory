import CoreLocation
import EventKit
import Foundation
import UserNotifications

final class NativePermissionRepository: NSObject, PermissionRepositoryProtocol {
    private let eventStore = EKEventStore()

    func notificationStatus() async -> PermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return Self.mapNotificationStatus(settings.authorizationStatus)
    }

    func locationStatus() async -> PermissionStatus {
        let status = await Task.detached { CLLocationManager().authorizationStatus }.value
        return Self.mapLocationStatus(status)
    }

    func calendarStatus() async -> PermissionStatus {
        Self.mapCalendarStatus(EKEventStore.authorizationStatus(for: .event))
    }

    func requestNotificationPermission() async -> PermissionStatus {
        let center = UNUserNotificationCenter.current()
        let currentStatus = await center.notificationSettings().authorizationStatus

        switch currentStatus {
        case .authorized, .provisional, .ephemeral:
            return .granted
        case .denied:
            return .denied
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                return granted ? .granted : .denied
            } catch {
                return .denied
            }
        @unknown default:
            return .denied
        }
    }

    func requestLocationPermission() async -> PermissionStatus {
        let locationServicesEnabled = await Task.detached { CLLocationManager.locationServicesEnabled() }.value
        guard locationServicesEnabled else {
            return .denied
        }

        let currentStatus = await Task.detached { CLLocationManager().authorizationStatus }.value
        if currentStatus != .notDetermined {
            return Self.mapLocationStatus(currentStatus)
        }

        let requestor = await MainActor.run { LocationPermissionRequestor() }
        return await requestor.requestWhenInUseAuthorization()
    }

    func requestCalendarPermission() async -> PermissionStatus {
        let currentStatus = EKEventStore.authorizationStatus(for: .event)

        switch currentStatus {
        case .fullAccess:
            return .granted
        case .denied, .restricted, .writeOnly:
            return .denied
        case .notDetermined:
            do {
                let granted = try await eventStore.requestFullAccessToEvents()
                return granted ? .granted : .denied
            } catch {
                return .denied
            }
        @unknown default:
            return .denied
        }
    }

    fileprivate static func mapNotificationStatus(_ status: UNAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized, .provisional, .ephemeral:
            return .granted
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    fileprivate static func mapLocationStatus(_ status: CLAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    fileprivate static func mapCalendarStatus(_ status: EKAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .fullAccess:
            return .granted
        case .denied, .restricted, .writeOnly:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }
}

private final class LocationPermissionRequestor: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<PermissionStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestWhenInUseAuthorization() async -> PermissionStatus {
        let status = await Task.detached { CLLocationManager().authorizationStatus }.value
        if status != .notDetermined {
            return NativePermissionRepository.mapLocationStatus(status)
        }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            Task { @MainActor in
                manager.requestWhenInUseAuthorization()
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation else {
            return
        }

        let status = manager.authorizationStatus
        guard status != .notDetermined else {
            return
        }

        self.continuation = nil
        continuation.resume(returning: NativePermissionRepository.mapLocationStatus(status))
    }
}
