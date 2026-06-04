struct RequestCalendarPermissionUseCase {
    private let repository: PermissionRepositoryProtocol
    init(repository: PermissionRepositoryProtocol) { self.repository = repository }
    func execute() -> PermissionStatus { repository.requestCalendarPermission() }
}
