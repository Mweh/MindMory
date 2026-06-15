import Foundation

struct CurrentLocationContext: Equatable {
    let latitude: Double
    let longitude: Double
    let horizontalAccuracy: Double
    let timestamp: Date
    let placemarkName: String?

    func distance(from candidate: ContextualMemoryLocation) -> Double {
        haversineDistance(
            latitude: latitude,
            longitude: longitude,
            otherLatitude: candidate.latitude,
            otherLongitude: candidate.longitude
        )
    }
}

struct ContextualMemoryLocation: Equatable {
    let latitude: Double
    let longitude: Double
}

struct CurrentEventContext: Identifiable, Equatable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let location: String?
    let isAllDay: Bool

    func isHappening(at date: Date) -> Bool {
        startDate <= date && date <= endDate
    }
}

struct ContextualMemoryContext: Equatable {
    let now: Date
    let currentLocation: CurrentLocationContext?
    let currentEvent: CurrentEventContext?

    var hasSignal: Bool {
        currentLocation != nil || currentEvent != nil
    }
}

enum ContextualMemoryMatchReason: Equatable {
    case favorite
    case currentEvent
    case veryNear
    case near
    case sameArea
    case sameDayPreviousYear
    case nearEventDate
    case recent
}

struct ContextualMemoryCandidate: Identifiable, Equatable {
    var id: String { assetLocalIdentifier }

    let assetLocalIdentifier: String
    let creationDate: Date?
    let location: ContextualMemoryLocation?
    let locationName: String?
    let isFavorite: Bool
    var score: Int
    var distanceMeters: Double?
    var notificationConfidenceScore: Int
    var matchedReasons: [ContextualMemoryMatchReason]
}

struct ContextualMemory: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let dateText: String
    let locationName: String?
    let assetLocalIdentifier: String
    let journalText: String?
    let tags: [String]
    let context: ContextualMemoryContext
    let score: Int
    let distanceMeters: Double?
    let notificationConfidenceScore: Int

    var asMemory: Memory {
        Memory(
            id: id,
            title: title,
            subtitle: subtitle,
            dateText: dateText,
            locationName: locationName,
            imageName: "",
            journalText: journalText,
            isFavorite: false,
            tags: tags
        )
    }
}

enum ContextualPermissionKind: Equatable {
    case location
    case calendar
    case photoLibrary
}

enum ContextualEmptyReason: Equatable {
    case noContext
    case noPhotos
    case noMatch
}

enum ContextualMemoryState: Equatable {
    case idle
    case loading
    case permissionRequired(ContextualPermissionKind)
    case empty(ContextualEmptyReason)
    case loaded(ContextualMemory)
    case error(String)
}

struct ContextualMemoryCache: Codable, Equatable {
    let assetLocalIdentifier: String
    let locationKey: String?
    let latitude: Double?
    let longitude: Double?
    let placemarkName: String?
    let eventIdentifier: String?
    let eventTitle: String?
    let eventStartDate: Date?
    let eventEndDate: Date?
    let discoveredAt: Date
    let memoryId: UUID
    let title: String
    let subtitle: String
    let dateText: String
    let locationName: String?
    let journalText: String?
    let tags: [String]

    var memory: Memory {
        Memory(
            id: memoryId,
            title: title,
            subtitle: subtitle,
            dateText: dateText,
            locationName: locationName,
            imageName: "",
            journalText: journalText,
            isFavorite: false,
            tags: tags
        )
    }

    func contextualMemory(context: ContextualMemoryContext) -> ContextualMemory {
        ContextualMemory(
            id: memoryId,
            title: title,
            subtitle: subtitle,
            dateText: dateText,
            locationName: locationName,
            assetLocalIdentifier: assetLocalIdentifier,
            journalText: journalText,
            tags: tags,
            context: context,
            score: 0,
            distanceMeters: nil,
            notificationConfidenceScore: 0
        )
    }
}

extension ContextualMemory {
    func makeCache(discoveredAt: Date = Date()) -> ContextualMemoryCache {
        ContextualMemoryCache(
            assetLocalIdentifier: assetLocalIdentifier,
            locationKey: context.currentLocation?.cacheKey,
            latitude: context.currentLocation?.latitude,
            longitude: context.currentLocation?.longitude,
            placemarkName: context.currentLocation?.placemarkName,
            eventIdentifier: context.currentEvent?.id,
            eventTitle: context.currentEvent?.title,
            eventStartDate: context.currentEvent?.startDate,
            eventEndDate: context.currentEvent?.endDate,
            discoveredAt: discoveredAt,
            memoryId: id,
            title: title,
            subtitle: subtitle,
            dateText: dateText,
            locationName: locationName,
            journalText: journalText,
            tags: tags
        )
    }
}

extension CurrentLocationContext {
    var cacheKey: String? {
        placemarkName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

private func haversineDistance(latitude: Double, longitude: Double, otherLatitude: Double, otherLongitude: Double) -> Double {
    let earthRadius = 6_371_000.0
    let deltaLatitude = (otherLatitude - latitude) * .pi / 180
    let deltaLongitude = (otherLongitude - longitude) * .pi / 180
    let latitude1 = latitude * .pi / 180
    let latitude2 = otherLatitude * .pi / 180

    let a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2)
        + sin(deltaLongitude / 2) * sin(deltaLongitude / 2) * cos(latitude1) * cos(latitude2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return earthRadius * c
}
