import Foundation

protocol MemoryRepositoryProtocol {
    func fetchMemories() -> [Memory]
    func fetchFavoriteMemories() -> [Memory]
    func saveJournalEntry(memoryID: UUID, text: String) -> Memory?
    func toggleFavorite(memoryID: UUID) -> Memory?
}
