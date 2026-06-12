import Foundation

struct FindContextualMemoryUseCase {
    let getCurrentLocationUseCase: GetCurrentLocationUseCase
    let getCurrentEventUseCase: GetCurrentEventUseCase
    let fetchPhotoAssetsUseCase: FetchPhotoAssetsUseCase
    let rankCandidatesUseCase: RankContextualMemoryCandidatesUseCase

    func execute(now: Date = Date()) async -> ContextualMemoryState {
        do {
            async let currentLocation = getCurrentLocationUseCase.execute()
            async let currentEvent = getCurrentEventUseCase.execute(at: now)

            let context = try await ContextualMemoryContext(
                now: now,
                currentLocation: currentLocation,
                currentEvent: currentEvent
            )

            guard context.hasSignal else {
                return .empty(.noContext)
            }

            let photoStatus = await fetchPhotoAssetsUseCase.authorizationStatus()
            switch photoStatus {
            case .granted:
                break
            case .notDetermined:
                guard await fetchPhotoAssetsUseCase.requestAuthorization() == .granted else {
                    return .permissionRequired(.photoLibrary)
                }
            case .denied:
                return .permissionRequired(.photoLibrary)
            }

            let candidates = try await fetchPhotoAssetsUseCase.execute(around: context)
            guard !candidates.isEmpty else {
                return .empty(.noPhotos)
            }

            let rankedCandidates = rankCandidatesUseCase.execute(candidates: candidates, context: context)
            guard let bestCandidate = rankedCandidates.first else {
                return .empty(.noMatch)
            }

            return .loaded(makeContextualMemory(from: bestCandidate, context: context))
        } catch {
            return .error(error.localizedDescription)
        }
    }

    private func makeContextualMemory(from candidate: ContextualMemoryCandidate, context: ContextualMemoryContext) -> ContextualMemory {
        ContextualMemory(
            id: UUID(),
            title: title(for: context, candidate: candidate),
            subtitle: subtitle(for: context),
            dateText: dateText(for: candidate.creationDate),
            locationName: context.currentEvent?.location ?? context.currentLocation?.placemarkName ?? candidate.locationName,
            assetLocalIdentifier: candidate.assetLocalIdentifier,
            journalText: nil,
            tags: candidate.matchedReasons.map(\.title),
            context: context,
            score: candidate.score,
            distanceMeters: candidate.distanceMeters,
            notificationConfidenceScore: candidate.notificationConfidenceScore
        )
    }

    private func title(for context: ContextualMemoryContext, candidate: ContextualMemoryCandidate) -> String {
        if let eventTitle = context.currentEvent?.title, !eventTitle.isEmpty {
            return eventTitle
        }

        if candidate.matchedReasons.contains(.veryNear) || candidate.matchedReasons.contains(.near) {
            return "You’ve been here before"
        }

        return "A memory from this moment"
    }

    private func subtitle(for context: ContextualMemoryContext) -> String {
        if context.currentEvent != nil {
            return "Here’s a memory connected to this moment."
        }

        return "A memory from around this place."
    }

    private func dateText(for date: Date?) -> String {
        guard let date else { return "Memory" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

private extension ContextualMemoryMatchReason {
    var title: String {
        switch self {
        case .favorite:
            return "Favorite"
        case .currentEvent:
            return "Event"
        case .veryNear:
            return "Very near"
        case .near:
            return "Nearby"
        case .sameArea:
            return "Same area"
        case .sameDayPreviousYear:
            return "On this day"
        case .nearEventDate:
            return "Event date"
        case .recent:
            return "Recent"
        }
    }
}
