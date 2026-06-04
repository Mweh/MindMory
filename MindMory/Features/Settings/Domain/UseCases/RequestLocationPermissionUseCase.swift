struct RequestLocationPermissionUseCase {
    private let repository: PermissionRepositoryProtocol
    init(repository: PermissionRepositoryProtocol) { self.repository = repository }
    func execute() -> PermissionStatus { repository.requestLocationPermission() }
}
