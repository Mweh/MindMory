import Foundation

struct RankContextualMemoryCandidatesUseCase {
    func execute(candidates: [ContextualMemoryCandidate], context: ContextualMemoryContext) -> [ContextualMemoryCandidate] {
        candidates
            .map { score(candidate: $0, context: context) }
            .filter { $0.score > 0 }
            .sorted { lhs, rhs in
                if lhs.score != rhs.score {
                    return lhs.score > rhs.score
                }

                return (lhs.creationDate ?? .distantPast) > (rhs.creationDate ?? .distantPast)
            }
    }

    private func score(candidate: ContextualMemoryCandidate, context: ContextualMemoryContext) -> ContextualMemoryCandidate {
        var scoredCandidate = candidate
        var score = 0
        var reasons: [ContextualMemoryMatchReason] = []

        if candidate.isFavorite {
            score += 1000
            reasons.append(.favorite)
        }

        if let event = context.currentEvent, isCandidateRelatedToEvent(candidate, event: event, now: context.now) {
            score += 700
            reasons.append(.currentEvent)
        }

        if let location = context.currentLocation, let candidateLocation = candidate.location {
            let distance = location.distance(from: candidateLocation)
            switch distance {
            case 0..<100:
                score += 500
                reasons.append(.veryNear)
            case 100..<500:
                score += 300
                reasons.append(.near)
            case 500..<2_000:
                reasons.append(.sameArea)
            default:
                break
            }
        }

        if isSameDayInPreviousYear(candidateDate: candidate.creationDate, now: context.now) {
            score += 250
            reasons.append(.sameDayPreviousYear)
        }

        if let event = context.currentEvent, isNearEventDate(candidateDate: candidate.creationDate, event: event) {
            score += 200
            reasons.append(.nearEventDate)
        }

        if isRecent(candidateDate: candidate.creationDate, now: context.now), score > 0 {
            score += 100
            reasons.append(.recent)
        }

        scoredCandidate.score = score
        scoredCandidate.matchedReasons = reasons
        return scoredCandidate
    }

    private func isCandidateRelatedToEvent(_ candidate: ContextualMemoryCandidate, event: CurrentEventContext, now: Date) -> Bool {
        guard event.isHappening(at: now) else { return false }
        return isNearEventDate(candidateDate: candidate.creationDate, event: event)
    }

    private func isNearEventDate(candidateDate: Date?, event: CurrentEventContext) -> Bool {
        guard let candidateDate else { return false }
        let interval = candidateDate.timeIntervalSince(event.startDate)
        let sixHours: TimeInterval = 6 * 60 * 60
        return abs(interval) <= sixHours || Calendar.current.isDate(candidateDate, inSameDayAs: event.startDate)
    }

    private func isSameDayInPreviousYear(candidateDate: Date?, now: Date) -> Bool {
        guard let candidateDate else { return false }
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.month, .day], from: now)
        let candidateComponents = calendar.dateComponents([.year, .month, .day], from: candidateDate)
        let nowYear = calendar.component(.year, from: now)

        return candidateComponents.year.map { $0 < nowYear } == true
            && candidateComponents.month == nowComponents.month
            && candidateComponents.day == nowComponents.day
    }

    private func isRecent(candidateDate: Date?, now: Date) -> Bool {
        guard let candidateDate else { return false }
        let oneYear: TimeInterval = 365 * 24 * 60 * 60
        return now.timeIntervalSince(candidateDate) <= oneYear
    }
}
