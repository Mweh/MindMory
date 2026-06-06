//
//  MockCalendarRepository.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 06/06/26.
//
import Foundation

final class MockCalendarRepository: CalendarRepositoryProtocol {
    private let events: [CalendarEvent]
    
    init(events: [CalendarEvent] = MockCalendarRepository.sampleEvents) {
        self.events = events
    }
    
    func fetchUpcomingEvents() async throws -> [CalendarEvent] {
        events
    }
    
    private static let sampleEvents: [CalendarEvent] = [
        CalendarEvent(
            id: "event-001",
            title: "Event 1",
            startDate: Date.now,
            endDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date.now)!,
            isAllDay: false
        ),
        CalendarEvent(
            id: "event-002",
            title: "Event 2",
            startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!,
            endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date.now)!,
            isAllDay: false
        ),
    ]
}
