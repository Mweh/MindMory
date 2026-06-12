import Foundation

struct FetchPhotoAssetsUseCase {
    let repository: PhotoLibraryRepositoryProtocol

    func authorizationStatus() async -> PermissionStatus {
        await repository.authorizationStatus()
    }

    func requestAuthorization() async -> PermissionStatus {
        await repository.requestAuthorization()
    }

    func execute(around context: ContextualMemoryContext) async throws -> [ContextualMemoryCandidate] {
        try await repository.fetchPhotoAssets(around: context)
    }
}
