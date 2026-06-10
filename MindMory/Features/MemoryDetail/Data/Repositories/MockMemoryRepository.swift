import Foundation

final class MockMemoryRepository: MemoryRepositoryProtocol {
    private var memories: [Memory]

    init(memories: [Memory] = PreviewData.memories) {
        self.memories = memories
    }

    func fetchMemories() -> [Memory] { memories }
    func fetchFavoriteMemories() -> [Memory] { memories.filter(\.isFavorite) }

    func saveJournalEntry(memoryID: UUID, text: String) -> Memory? {
        guard let index = memories.firstIndex(where: { $0.id == memoryID }) else { return nil }
        memories[index].journalText = text
        return memories[index]
    }

    func toggleFavorite(memoryID: UUID) -> Memory? {
        guard let index = memories.firstIndex(where: { $0.id == memoryID }) else { return nil }
        memories[index].isFavorite.toggle()
        return memories[index]
    }
}
