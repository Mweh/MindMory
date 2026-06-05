struct RequestCalendarPermissionUseCase {
    private let repository: PermissionRepositoryProtocol
    init(repository: PermissionRepositoryProtocol) { self.repository = repository }
    func execute() async -> PermissionStatus { await repository.requestCalendarPermission() }
}
