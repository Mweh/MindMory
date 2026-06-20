import Foundation

struct FetchLocationPhotoListsUseCase {
    let repository: PhotoLibraryRepositoryProtocol

    func authorizationStatus() async -> PermissionStatus {
        await repository.authorizationStatus()
    }

    func requestAuthorization() async -> PermissionStatus {
        await repository.requestAuthorization()
    }

    func fetchFavoritePhotoAsset(near location: CurrentLocationContext, maxDistanceMeters: Double = 1_000) async throws -> String? {
        try await repository.fetchLatestFavoritePhotoAsset(near: location, maxDistanceMeters: maxDistanceMeters)
    }

    func fetchRecentPhotoAssets(near location: CurrentLocationContext, maxDistanceMeters: Double = 1_000, limit: Int = 3) async throws -> [String] {
        try await repository.fetchRecentPhotoAssets(near: location, maxDistanceMeters: maxDistanceMeters, limit: limit)
    }

    func fetchRecentPhotoAssetsWithPeople(near location: CurrentLocationContext, maxDistanceMeters: Double = 1_000, limit: Int = 3) async throws -> [String] {
        try await repository.fetchRecentPhotoAssetsWithPeople(near: location, maxDistanceMeters: maxDistanceMeters, limit: limit)
    }
}
