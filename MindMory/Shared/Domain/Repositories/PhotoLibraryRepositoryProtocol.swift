import Foundation

protocol PhotoLibraryRepositoryProtocol {
    func authorizationStatus() async -> PermissionStatus
    func requestAuthorization() async -> PermissionStatus
    func fetchPhotoAssets(around context: ContextualMemoryContext) async throws -> [ContextualMemoryCandidate]
}

protocol ContextualMemoryCacheRepositoryProtocol {
    func load() -> ContextualMemoryCache?
    func save(_ cache: ContextualMemoryCache)
    func clear()
}
