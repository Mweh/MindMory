import Foundation

struct FetchRecentLocationPhotoUseCase {
    let repository: PhotoLibraryRepositoryProtocol

    func authorizationStatus() async -> PermissionStatus {
        await repository.authorizationStatus()
    }

    func requestAuthorization() async -> PermissionStatus {
        await repository.requestAuthorization()
    }

    func execute(near location: CurrentLocationContext, maxDistanceMeters: Double = 1_000) async throws -> String? {
        try await repository.fetchLatestPhotoAsset(near: location, maxDistanceMeters: maxDistanceMeters)
    }
}
