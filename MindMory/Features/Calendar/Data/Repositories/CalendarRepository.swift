//
//  CalendarRepository.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 20/06/26.
//

import EventKit

final class CalendarRepository: CalendarRepositoryProtocol {
    private let store: EKEventStore

    enum CalendarError: Error {
        case accessDenied
    }

    init(store: EKEventStore = EKEventStore()) {
        self.store = store
    }

    func fetchUpcomingEvents() async throws -> [CalendarEvent] {
        // Only check status — don't request permission here.
        // Permission is requested during onboarding via NativePermissionRepository.
        guard EKEventStore.authorizationStatus(for: .event) == .fullAccess else {
            throw CalendarError.accessDenied
        }

        let now = Date.now
        let sevenDaysAhead = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        let predicate = store.predicateForEvents(withStart: now, end: sevenDaysAhead, calendars: nil)
        let ekEvents = store.events(matching: predicate)

        return ekEvents.map { event in
            CalendarEvent(
                id: event.eventIdentifier,
                title: event.title ?? "Untitled",
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay
            )
        }
    }
}
