struct RequestNotificationPermissionUseCase {
    private let repository: PermissionRepositoryProtocol
    init(repository: PermissionRepositoryProtocol) { self.repository = repository }
    func execute() async -> PermissionStatus { await repository.requestNotificationPermission() }
}
