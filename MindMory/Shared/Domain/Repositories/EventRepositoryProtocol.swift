import Foundation

protocol EventRepositoryProtocol {
    func authorizationStatus() async -> PermissionStatus
    func requestAuthorization() async -> PermissionStatus
    func getCurrentEvent(at date: Date) async throws -> CurrentEventContext?
}
