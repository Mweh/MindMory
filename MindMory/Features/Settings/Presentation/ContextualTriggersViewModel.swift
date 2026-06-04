import SwiftUI
import Combine

final class ContextualTriggersViewModel: ObservableObject {
    @Published var settings: ContextTriggerSettings
    private let repository: ContextRepositoryProtocol
    init(repository: ContextRepositoryProtocol) { self.repository = repository; self.settings = repository.fetchTriggerSettings() }
    func save() { settings = repository.updateTriggerSettings(settings) }
}
