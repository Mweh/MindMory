//
//  MockCalendarRepository.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 20/06/26.
//

import Foundation

final class MockCalendarRepository: CalendarRepositoryProtocol {
    private let events: [CalendarEvent]

    init(events: [CalendarEvent] = []) {
        self.events = events
    }

    func fetchUpcomingEvents() async throws -> [CalendarEvent] { events }
}
