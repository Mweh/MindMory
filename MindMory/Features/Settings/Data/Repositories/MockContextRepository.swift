final class MockContextRepository: ContextRepositoryProtocol {
    private var settings: ContextTriggerSettings

    init(settings: ContextTriggerSettings = PreviewData.triggerSettings) {
        self.settings = settings
    }

    func fetchTriggerSettings() -> ContextTriggerSettings { settings }

    func updateTriggerSettings(_ settings: ContextTriggerSettings) -> ContextTriggerSettings {
        self.settings = settings
        return settings
    }
}
