//
//  CalendarEvent.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 20/06/26.
//
import Foundation

struct CalendarEvent: Identifiable, Equatable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
}
