import Foundation

struct SaveJournalEntryUseCase {
    private let repository: MemoryRepositoryProtocol
    init(repository: MemoryRepositoryProtocol) { self.repository = repository }
    func execute(memoryID: UUID, text: String) -> Memory? { repository.saveJournalEntry(memoryID: memoryID, text: text) }
}
