import Foundation
import Photos

final class PhotoLibraryRepository: PhotoLibraryRepositoryProtocol {
    func authorizationStatus() async -> PermissionStatus {
        mapAuthorizationStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    func requestAuthorization() async -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .notDetermined else {
            return mapAuthorizationStatus(status)
        }

        let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return mapAuthorizationStatus(newStatus)
    }

    func fetchPhotoAssets(around context: ContextualMemoryContext) async throws -> [ContextualMemoryCandidate] {
        guard mapAuthorizationStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite)) == .granted else {
            return []
        }

        let options = PHFetchOptions()
        options.predicate = makePredicate(for: context)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 500

        let assets = PHAsset.fetchAssets(with: .image, options: options)
        var candidates: [ContextualMemoryCandidate] = []
        candidates.reserveCapacity(assets.count)

        assets.enumerateObjects { asset, _, _ in
            candidates.append(ContextualMemoryCandidate(
                assetLocalIdentifier: asset.localIdentifier,
                creationDate: asset.creationDate,
                location: asset.location.map {
                    ContextualMemoryLocation(
                        latitude: $0.coordinate.latitude,
                        longitude: $0.coordinate.longitude
                    )
                },
                locationName: nil,
                isFavorite: asset.isFavorite,
                score: 0,
                distanceMeters: nil,
                notificationConfidenceScore: 0,
                matchedReasons: []
            ))
        }

        return candidates
    }

    func fetchLatestPhotoAsset(near location: CurrentLocationContext, maxDistanceMeters: Double) async throws -> String? {
        guard mapAuthorizationStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite)) == .granted else {
            return nil
        }

        let identifiers = fetchNearbyPhotoAssetIdentifiers(
            near: location,
            maxDistanceMeters: maxDistanceMeters,
            fetchLimit: 1
        ) { _ in true }

        return identifiers.first
    }

    func fetchLatestFavoritePhotoAsset(near location: CurrentLocationContext, maxDistanceMeters: Double) async throws -> String? {
        guard mapAuthorizationStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite)) == .granted else {
            return nil
        }

        let identifiers = fetchNearbyPhotoAssetIdentifiers(
            near: location,
            maxDistanceMeters: maxDistanceMeters,
            fetchLimit: 1
        ) { asset in
            asset.isFavorite
        }

        return identifiers.first
    }

    func fetchPhotoAssetsWithPeople(near location: CurrentLocationContext, maxDistanceMeters: Double, limit: Int) async throws -> [String] {
        guard mapAuthorizationStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite)) == .granted else {
            return []
        }

        return fetchNearbyPhotoAssetIdentifiers(
            near: location,
            maxDistanceMeters: maxDistanceMeters,
            fetchLimit: limit
        ) { asset in
            self.assetContainsPeople(asset)
        }
    }

    func fetchRecentPhotoAssets(near location: CurrentLocationContext, maxDistanceMeters: Double, limit: Int) async throws -> [String] {
        guard mapAuthorizationStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite)) == .granted else {
            return []
        }

        return fetchNearbyPhotoAssetIdentifiers(
            near: location,
            maxDistanceMeters: maxDistanceMeters,
            fetchLimit: limit
        ) { _ in true }
    }

    private func fetchNearbyPhotoAssetIdentifiers(
        near location: CurrentLocationContext,
        maxDistanceMeters: Double,
        fetchLimit: Int,
        filter: @escaping (PHAsset) -> Bool
    ) -> [String] {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.includeHiddenAssets = false
        options.fetchLimit = 500

        let assets = PHAsset.fetchAssets(with: .image, options: options)
        var identifiers: [String] = []
        identifiers.reserveCapacity(min(fetchLimit, 20))

        assets.enumerateObjects { asset, _, stop in
            autoreleasepool {
                guard
                    let assetLocation = asset.location,
                    location.distance(from: ContextualMemoryLocation(
                        latitude: assetLocation.coordinate.latitude,
                        longitude: assetLocation.coordinate.longitude
                    )) <= maxDistanceMeters,
                    filter(asset)
                else {
                    return
                }

                identifiers.append(asset.localIdentifier)
                if identifiers.count >= fetchLimit {
                    stop.pointee = true
                }
            }
        }

        return identifiers
    }

    private func assetContainsPeople(_ asset: PHAsset) -> Bool {
        if #available(iOS 16, *) {
            if let peopleIdentifiers = asset.value(forKey: "personLocalIdentifiers") as? [String] {
                return !peopleIdentifiers.isEmpty
            }
        }

        return false
    }

    private func makePredicate(for context: ContextualMemoryContext) -> NSPredicate {
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue))

        if let event = context.currentEvent {
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: event.startDate)
            let dayEnd = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: dayStart) ?? event.endDate
            predicates.append(NSPredicate(format: "creationDate >= %@ AND creationDate <= %@", dayStart as NSDate, dayEnd as NSDate))
        } else {
            let fallbackStart = Calendar.current.date(byAdding: .year, value: -8, to: context.now) ?? context.now
            predicates.append(NSPredicate(format: "creationDate >= %@", fallbackStart as NSDate))
        }

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    private func mapAuthorizationStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized, .limited:
            return .granted
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
}

