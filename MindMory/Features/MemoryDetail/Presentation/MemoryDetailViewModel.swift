import SwiftUI
import Combine

final class MemoryDetailViewModel: ObservableObject {

    @Published private(set) var memory: Memory
    @Published var journalText: String
    @Published private(set) var shareableMemory: ShareableMemory?

    private let saveJournalEntryUseCase: SaveJournalEntryUseCase
    private let toggleFavoriteMemoryUseCase: ToggleFavoriteMemoryUseCase
    private let generateShareableMemoryUseCase: GenerateShareableMemoryUseCase

    init(
        memory: Memory,
        saveJournalEntryUseCase: SaveJournalEntryUseCase,
        toggleFavoriteMemoryUseCase: ToggleFavoriteMemoryUseCase,
        generateShareableMemoryUseCase: GenerateShareableMemoryUseCase
    ) {
        self.memory = memory
        self.journalText = memory.journalText ?? ""
        self.saveJournalEntryUseCase = saveJournalEntryUseCase
        self.toggleFavoriteMemoryUseCase = toggleFavoriteMemoryUseCase
        self.generateShareableMemoryUseCase = generateShareableMemoryUseCase
    }

    func saveJournal() {
        if let updatedMemory = saveJournalEntryUseCase.execute(
            memoryID: memory.id,
            text: journalText
        ) {
            memory = updatedMemory
        }
    }

    func toggleFavorite() {
        if let updatedMemory = toggleFavoriteMemoryUseCase.execute(memoryID: memory.id) {
            memory = updatedMemory
        }
    }

    func prepareShareFrame() {
        shareableMemory = generateShareableMemoryUseCase.execute(memory: memory)
    }
}
