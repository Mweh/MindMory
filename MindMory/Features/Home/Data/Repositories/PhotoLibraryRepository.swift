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

        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 500

        let assets = PHAsset.fetchAssets(with: .image, options: options)
        var matchingIdentifier: String?

        assets.enumerateObjects { asset, _, stop in
            guard
                let assetLocation = asset.location,
                location.distance(from: ContextualMemoryLocation(
                    latitude: assetLocation.coordinate.latitude,
                    longitude: assetLocation.coordinate.longitude
                )) <= maxDistanceMeters
            else {
                return
            }

            matchingIdentifier = asset.localIdentifier
            stop.pointee = true
        }

        return matchingIdentifier
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

