struct ShareableMemory: Equatable {
    let title: String
    let dateText: String
    let message: String
    let locationName: String?
}

struct GenerateShareableMemoryUseCase {
    func execute(memory: Memory) -> ShareableMemory {
        ShareableMemory(title: memory.title, dateText: memory.dateText, message: memory.subtitle, locationName: memory.locationName)
    }
}
