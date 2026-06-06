//
//  CalendarRepositoryProtocol.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 06/06/26.
//
import Foundation

protocol CalendarRepositoryProtocol {
    func fetchUpcomingEvents() async throws -> [CalendarEvent]
}
