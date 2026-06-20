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

    func fetchPeoplePhotoAssets(near location: CurrentLocationContext, maxDistanceMeters: Double = 1_000, limit: Int = 3) async throws -> [String] {
        try await repository.fetchPhotoAssetsWithPeople(near: location, maxDistanceMeters: maxDistanceMeters, limit: limit)
    }

    func fetchRecentPhotoAssets(near location: CurrentLocationContext, maxDistanceMeters: Double = 1_000, limit: Int = 4) async throws -> [String] {
        try await repository.fetchRecentPhotoAssets(near: location, maxDistanceMeters: maxDistanceMeters, limit: limit)
    }
}
