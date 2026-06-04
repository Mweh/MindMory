struct GetAlbumMemoriesUseCase {
    private let repository: MemoryRepositoryProtocol
    init(repository: MemoryRepositoryProtocol) { self.repository = repository }
    func execute() -> [Memory] { repository.fetchMemories() }
}
