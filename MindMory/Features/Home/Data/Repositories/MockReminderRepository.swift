final class MockReminderRepository: ReminderRepositoryProtocol {
    private let reminder: Reminder?

    init(reminder: Reminder? = PreviewData.reminder) {
        self.reminder = reminder
    }

    func fetchTodayReminder() -> Reminder? { reminder }
}
