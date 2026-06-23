import CoreLocation
import Foundation

@MainActor
final class CoreLocationRepository: NSObject, LocationRepositoryProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<PermissionStatus, Never>?
    private var locationContinuation: CheckedContinuation<CurrentLocationContext?, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .other
    }

    func authorizationStatus() async -> PermissionStatus {
        let status = locationManager.authorizationStatus
        print("Authorization status:", status.rawValue)
        return mapAuthorizationStatus(status)
    }

    func requestAuthorization() async -> PermissionStatus {
        let status = await Task.detached { [locationManager] in
            locationManager.authorizationStatus
        }.value

        guard status == .notDetermined else {
            return mapAuthorizationStatus(status)
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            Task { @MainActor in
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    func requestAlwaysAuthorization() async -> PermissionStatus {
        let status = await Task.detached { [locationManager] in
            locationManager.authorizationStatus
        }.value

        if status == .authorizedAlways {
            return .granted
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            Task { @MainActor in
                locationManager.requestAlwaysAuthorization()
            }
        }
    }

    func getCurrentLocation() async throws -> CurrentLocationContext? {
        guard CLLocationManager.locationServicesEnabled() else { return nil }

        let status = locationManager.authorizationStatus
        guard status == .authorizedAlways || status == .authorizedWhenInUse else { return nil }

        if let location = locationManager.location, isRecent(location) {
            return await makeCurrentLocationContext(from: location)
        }

        return try await requestLocationUpdate(timeout: 10)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationContinuation?.resume(returning: mapAuthorizationStatus(manager.authorizationStatus))
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let bestLocation = locations
            .filter { $0.horizontalAccuracy >= 0 }
            .sorted(by: { $0.horizontalAccuracy < $1.horizontalAccuracy })
            .first

        print("locationManager(_:didUpdateLocations:) fired. Received \(locations.count) locations. Best accuracy: \(bestLocation?.horizontalAccuracy ?? -1)")

        guard let location = bestLocation else {
            if let continuation = locationContinuation {
                locationContinuation = nil
                continuation.resume(returning: nil)
            }
            return
        }

        NotificationCenter.default.post(
            name: NSNotification.Name("SignificantLocationChanged"),
            object: nil,
            userInfo: ["location": location]
        )

        guard let continuation = locationContinuation else { return }

        locationContinuation = nil
        Task { @MainActor in
            manager.stopUpdatingLocation()
        }

        Task { @MainActor [weak self] in
            guard let self else { return }
            let placemarkName = await self.getPlacemarkName(for: location)
            guard !Task.isCancelled else { return }
            continuation.resume(returning: CurrentLocationContext(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                horizontalAccuracy: location.horizontalAccuracy,
                timestamp: location.timestamp,
                placemarkName: placemarkName
            ))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil
        Task { @MainActor in
            manager.stopUpdatingLocation()
        }

        if let clError = error as? CLError, clError.code == .locationUnknown,
           let location = locationManager.location, isRecent(location) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                let placemarkName = await self.getPlacemarkName(for: location)
                guard !Task.isCancelled else { return }
                continuation.resume(returning: CurrentLocationContext(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    horizontalAccuracy: location.horizontalAccuracy,
                    timestamp: location.timestamp,
                    placemarkName: placemarkName
                ))
            }
            return
        }

        continuation.resume(throwing: error)
    }

    func startMonitoringSignificantLocationChanges() {
        guard CLLocationManager.significantLocationChangeMonitoringAvailable() else {
            print("Significant location changes are not available on this device.")
            return
        }
        Task { @MainActor in
            #if DEBUG
            locationManager.distanceFilter = 100
            locationManager.startUpdatingLocation()
            print("Started DEBUG location updates (distanceFilter = 100)")
            #else
            locationManager.startMonitoringSignificantLocationChanges()
            print("Started monitoring significant location changes")
            #endif
        }
    }

    func stopMonitoringSignificantLocationChanges() {
        Task { @MainActor in
            #if DEBUG
            locationManager.stopUpdatingLocation()
            print("Stopped DEBUG location updates")
            #else
            locationManager.stopMonitoringSignificantLocationChanges()
            print("Stopped monitoring significant location changes")
            #endif
        }
    }

    private func requestLocationUpdate(timeout: TimeInterval) async throws -> CurrentLocationContext? {
        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                locationContinuation = continuation
                Task { @MainActor in
                    locationManager.startUpdatingLocation()
                }

                Task { @MainActor [weak self] in
                    try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    guard let self, let pendingContinuation = self.locationContinuation else { return }
                    self.locationContinuation = nil
                    self.locationManager.stopUpdatingLocation()

                    if let location = self.locationManager.location, self.isRecent(location) {
                        let context = await self.makeCurrentLocationContext(from: location)
                        pendingContinuation.resume(returning: context)
                    } else {
                        pendingContinuation.resume(returning: nil)
                    }
                }
            }
        }, onCancel: {
            Task { @MainActor in
                self.locationManager.stopUpdatingLocation()
                self.locationContinuation = nil
            }
        })
    }

    private func makeCurrentLocationContext(from location: CLLocation) async -> CurrentLocationContext {
        CurrentLocationContext(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            horizontalAccuracy: location.horizontalAccuracy,
            timestamp: location.timestamp,
            placemarkName: await getPlacemarkName(for: location)
        )
    }

    func getPlacemarkName(for location: CLLocation) async -> String? {
        let localGeocoder = CLGeocoder()
        return await withCheckedContinuation { continuation in
            localGeocoder.reverseGeocodeLocation(location) { placemarks, _ in
                let placemark = placemarks?.first
                let nameParts = [placemark?.name, placemark?.locality, placemark?.subLocality]
                    .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                continuation.resume(returning: nameParts.isEmpty ? nil : nameParts.joined(separator: ", "))
            }
        }
    }

    private func isRecent(_ location: CLLocation) -> Bool {
        abs(location.timestamp.timeIntervalSinceNow) <= 20
    }

    private func mapAuthorizationStatus(_ status: CLAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            return .granted
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
}
