import Foundation

protocol PhotoLibraryRepositoryProtocol {
    func authorizationStatus() async -> PermissionStatus
    func requestAuthorization() async -> PermissionStatus
    func fetchPhotoAssets(around context: ContextualMemoryContext) async throws -> [ContextualMemoryCandidate]
}
