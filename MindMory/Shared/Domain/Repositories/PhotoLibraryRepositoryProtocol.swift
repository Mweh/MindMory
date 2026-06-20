import Foundation

protocol PhotoLibraryRepositoryProtocol {
    func authorizationStatus() async -> PermissionStatus
    func requestAuthorization() async -> PermissionStatus
    func fetchPhotoAssets(around context: ContextualMemoryContext) async throws -> [ContextualMemoryCandidate]
    func fetchLatestPhotoAsset(near location: CurrentLocationContext, maxDistanceMeters: Double) async throws -> String?
}

protocol ContextualMemoryCacheRepositoryProtocol {
    func load() -> ContextualMemoryCache?
    func save(_ cache: ContextualMemoryCache)
    func clear()
}
