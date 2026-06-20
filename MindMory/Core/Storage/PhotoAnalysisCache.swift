import Foundation

public protocol PhotoAnalysisCache: Sendable {
    func getResult(for assetIdentifier: String) async -> PhotoAnalysisResult?
    func saveResult(_ result: PhotoAnalysisResult) async
    func loadAll() async
}

public actor DiskPhotoAnalysisCache: PhotoAnalysisCache {
    private var cache: [String: PhotoAnalysisResult] = [:]
    private let fileURL: URL
    
    public init() {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        self.fileURL = urls[0].appendingPathComponent("PhotoAnalysisCache_v2.json")
    }
    
    public func getResult(for assetIdentifier: String) -> PhotoAnalysisResult? {
        return cache[assetIdentifier]
    }
    
    public func saveResult(_ result: PhotoAnalysisResult) {
        cache[result.assetIdentifier] = result
        saveToDisk()
    }
    
    public func loadAll() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([String: PhotoAnalysisResult].self, from: data) else {
            return
        }
        self.cache = decoded
    }
    
    private func saveToDisk() {
        let currentCache = self.cache
        let url = self.fileURL
        Task.detached {
            do {
                let data = try JSONEncoder().encode(currentCache)
                try data.write(to: url)
            } catch {
                print("Failed to save PhotoAnalysisCache: \(error)")
            }
        }
    }
}
