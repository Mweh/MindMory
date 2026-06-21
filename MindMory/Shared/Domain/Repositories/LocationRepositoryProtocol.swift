import Foundation
import CoreLocation

protocol LocationRepositoryProtocol {
    func authorizationStatus() async -> PermissionStatus
    func requestAuthorization() async -> PermissionStatus
    func requestAlwaysAuthorization() async -> PermissionStatus
    func getCurrentLocation() async throws -> CurrentLocationContext?
    func startMonitoringSignificantLocationChanges()
    func stopMonitoringSignificantLocationChanges()
    func getPlacemarkName(for location: CLLocation) async -> String?
}
