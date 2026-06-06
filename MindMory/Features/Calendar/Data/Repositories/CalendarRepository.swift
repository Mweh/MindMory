//
//  CalendarRepository.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 06/06/26.
//

import EventKit
import Foundation

final class CalendarRepository: CalendarRepositoryProtocol {
    private let store = EKEventStore()
    
    enum CalendarError: Error {
        case accessDenied
    }
    
    func fetchUpcomingEvents() async throws -> [CalendarEvent] {
        let granted = try await store.requestFullAccessToEvents()
        
        guard granted else {
            throw CalendarError.accessDenied
        }
        
        let now = Date.now
        let sevenDaysFromNow = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        
        let predicate = store.predicateForEvents(withStart: now,end: sevenDaysFromNow, calendars: nil)
        
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
