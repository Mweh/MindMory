import CoreLocation
import Foundation

final class CoreLocationRepository: NSObject, LocationRepositoryProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<PermissionStatus, Never>?
    private var locationContinuation: CheckedContinuation<CurrentLocationContext?, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func authorizationStatus() async -> PermissionStatus {
        mapAuthorizationStatus(locationManager.authorizationStatus)
    }

    func requestAuthorization() async -> PermissionStatus {
        let status = locationManager.authorizationStatus
        guard status == .notDetermined else {
            return mapAuthorizationStatus(status)
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func getCurrentLocation() async throws -> CurrentLocationContext? {
        guard CLLocationManager.locationServicesEnabled() else { return nil }

        let status = locationManager.authorizationStatus
        guard status == .authorizedAlways || status == .authorizedWhenInUse else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationContinuation?.resume(returning: mapAuthorizationStatus(manager.authorizationStatus))
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.sorted(by: { $0.horizontalAccuracy < $1.horizontalAccuracy }).first else {
            locationContinuation?.resume(returning: nil)
            locationContinuation = nil
            return
        }

        locationContinuation?.resume(returning: CurrentLocationContext(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            timestamp: location.timestamp,
            placemarkName: nil
        ))
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }

    private func mapAuthorizationStatus(_ status: CLAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorizedAlways, .authorizedWhenInUse:
            return .granted
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
}
