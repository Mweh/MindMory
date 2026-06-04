import Foundation

struct ToggleFavoriteMemoryUseCase {

    private let repository: MemoryRepositoryProtocol

    init(repository: MemoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(memoryID: UUID) -> Memory? {
        repository.toggleFavorite(memoryID: memoryID)
    }
}
