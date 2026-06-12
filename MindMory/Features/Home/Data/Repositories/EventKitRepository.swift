import EventKit
import Foundation

final class EventKitRepository: EventRepositoryProtocol {
    private let eventStore: EKEventStore

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }

    func authorizationStatus() async -> PermissionStatus {
        mapAuthorizationStatus(EKEventStore.authorizationStatus(for: .event))
    }

    func requestAuthorization() async -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .event)
        guard status == .notDetermined else {
            return mapAuthorizationStatus(status)
        }

        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            return granted ? .granted : .denied
        } catch {
            return .denied
        }
    }

    func getCurrentEvent(at date: Date) async throws -> CurrentEventContext? {
        guard mapAuthorizationStatus(EKEventStore.authorizationStatus(for: .event)) == .granted else {
            return nil
        }

        let searchStart = Calendar.current.date(byAdding: .hour, value: -12, to: date) ?? date
        let searchEnd = Calendar.current.date(byAdding: .hour, value: 12, to: date) ?? date
        let predicate = eventStore.predicateForEvents(withStart: searchStart, end: searchEnd, calendars: nil)
        let events = eventStore.events(matching: predicate)
            .filter { $0.startDate <= date && date <= $0.endDate }
            .sorted { lhs, rhs in
                if lhs.isAllDay != rhs.isAllDay {
                    return !lhs.isAllDay
                }

                let lhsDuration = lhs.endDate.timeIntervalSince(lhs.startDate)
                let rhsDuration = rhs.endDate.timeIntervalSince(rhs.startDate)
                if lhsDuration != rhsDuration {
                    return lhsDuration < rhsDuration
                }

                return lhs.startDate < rhs.startDate
            }

        guard let event = events.first else { return nil }

        return CurrentEventContext(
            id: event.eventIdentifier ?? UUID().uuidString,
            title: event.title ?? "this event",
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.location,
            isAllDay: event.isAllDay
        )
    }

    private func mapAuthorizationStatus(_ status: EKAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .fullAccess:
            return .granted
        case .denied, .restricted, .writeOnly:
            return .denied
        @unknown default:
            return .denied
        }
    }
}
