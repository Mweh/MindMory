//
//  CalendarNotificationCoordinator.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 20/06/26.
//
import Foundation
import UserNotifications

final class CalendarNotificationCoordinator {
    private let permissionRepository: PermissionRepositoryProtocol
    private let fetchUpcomingCalendarEventsUseCase: FetchUpcomingCalendarEventsUseCase
    private let notificationCenter: UNUserNotificationCenter

    init(
        permissionRepository: PermissionRepositoryProtocol,
        fetchUpcomingCalendarEventsUseCase: FetchUpcomingCalendarEventsUseCase,
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.permissionRepository = permissionRepository
        self.fetchUpcomingCalendarEventsUseCase = fetchUpcomingCalendarEventsUseCase
        self.notificationCenter = notificationCenter
    }

    func scheduleUpcomingEventNotifications() async {
        guard await permissionRepository.notificationStatus() == .granted,
              await permissionRepository.calendarStatus() == .granted else { return }

        do {
            let events = try await fetchUpcomingCalendarEventsUseCase.execute()
            for event in events {
                // Remind 15 minutes before the event starts
                let reminderDate = event.startDate.addingTimeInterval(0)
                guard reminderDate > Date.now else { continue }
                await scheduleNotification(for: event, at: reminderDate)
            }
        } catch {
            print("Failed to fetch events for notification: \(error)")
        }
    }

    private func scheduleNotification(for event: CalendarEvent, at date: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Your event is starting!"
        content.body = "\"\(event.title)\" started. A great moment to capture!"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "calendarEvent.\(event.id)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule notification event: \(error)")
        }
    }
}
