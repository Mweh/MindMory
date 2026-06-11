import Foundation

protocol LocationRepositoryProtocol {
    func authorizationStatus() async -> PermissionStatus
    func requestAuthorization() async -> PermissionStatus
    func getCurrentLocation() async throws -> CurrentLocationContext?
}
