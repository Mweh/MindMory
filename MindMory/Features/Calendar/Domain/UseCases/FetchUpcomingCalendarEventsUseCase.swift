//
//  FetchUpcomingCalendarEventsUseCase.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 20/06/26.
//

struct FetchUpcomingCalendarEventsUseCase {
    private let repository: CalendarRepositoryProtocol
    init(repository: CalendarRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> [CalendarEvent] { try await repository.fetchUpcomingEvents() }
}
