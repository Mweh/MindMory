import SwiftUI
import Combine

enum HomeViewState: Equatable { case loading, positive(Reminder, Memory?), empty, permissionRequired, error(String) }

final class HomeViewModel: ObservableObject {
    @Published private(set) var state: HomeViewState = .loading
    private let getTodayReminderUseCase: GetTodayReminderUseCase
    private let memories: [Memory]
    init(getTodayReminderUseCase: GetTodayReminderUseCase, memories: [Memory]) { self.getTodayReminderUseCase = getTodayReminderUseCase; self.memories = memories }
    func load() { if let reminder = getTodayReminderUseCase.execute() { state = .positive(reminder, memories.first) } else { state = .empty } }
    func favoriteTapped() {}
    func shareTapped() {}
}
