struct GetTodayReminderUseCase {
    private let repository: ReminderRepositoryProtocol
    init(repository: ReminderRepositoryProtocol) { self.repository = repository }
    func execute() -> Reminder? { repository.fetchTodayReminder() }
}
