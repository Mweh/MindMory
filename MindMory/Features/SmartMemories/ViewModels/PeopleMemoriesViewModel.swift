import Foundation
import Photos
import SwiftUI
import Combine

@MainActor
public final class PeopleMemoriesViewModel: ObservableObject {
    @Published public var state: ViewState = .idle
    @Published public var analyzedCount: Int = 0
    @Published public var totalToAnalyze: Int = 0
    @Published public var memories: [MemoryItem] = []
    
    public enum ViewState {
        case idle
        case loading
        case analyzing
        case empty
        case loaded
        case error(String)
        case permissionDenied
    }
    
    public struct MemoryItem: Identifiable, Equatable {
        public var id: String { asset.localIdentifier }
        public let asset: PHAsset
        public let score: MemoryScore
        
        public static func == (lhs: MemoryItem, rhs: MemoryItem) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    private let libraryService: PhotoLibraryService
    private let analysisService: PhotoAnalysisService
    private let cache: PhotoAnalysisCache
    private var currentTask: Task<Void, Never>?
    
    public init(
        libraryService: PhotoLibraryService,
        analysisService: PhotoAnalysisService,
        cache: PhotoAnalysisCache
    ) {
        self.libraryService = libraryService
        self.analysisService = analysisService
        self.cache = cache
    }
    
    public func loadMemories() {
        currentTask?.cancel()
        currentTask = Task {
            do {
                self.state = .loading
                let authorized = await libraryService.requestAuthorization()
                guard authorized else {
                    self.state = .permissionDenied
                    return
                }
                
                await cache.loadAll()
                let assets = await libraryService.fetchAssets()
                guard !assets.isEmpty else {
                    self.state = .empty
                    return
                }
                
                self.totalToAnalyze = assets.count
                self.analyzedCount = 0
                self.state = .analyzing
                
                print("DEBUG: Fetched assets:", assets.count)
                
                let memoryItems = try await Self.processAssets(
                    assets,
                    cache: cache,
                    analysisService: analysisService
                ) { [weak self] in
                    await MainActor.run {
                        self?.analyzedCount += 1
                    }
                }
                
                let sortedItems = memoryItems.sorted { $0.score > $1.score }
                
                let peopleItems = sortedItems.filter { $0.score.containsPerson }
                
                print("DEBUG: People photos:", peopleItems.count)
                print("DEBUG: Loading: false")
                
                self.memories = peopleItems
                self.state = peopleItems.isEmpty ? .empty : .loaded
                
            } catch {
                self.state = .error(error.localizedDescription)
            }
        }
    }
    
    public func cancel() {
        currentTask?.cancel()
        state = .idle
    }
    
    private nonisolated static func processAssets(
        _ assets: [PHAsset],
        cache: PhotoAnalysisCache,
        analysisService: PhotoAnalysisService,
        updateProgress: @Sendable @escaping () async -> Void
    ) async throws -> [MemoryItem] {
        let maxConcurrent = 4
        
        return try await withThrowingTaskGroup(of: MemoryItem?.self) { group in
            var items: [MemoryItem] = []
            var activeTasks = 0
            var iterator = assets.makeIterator()
            
            while activeTasks < maxConcurrent, let asset = iterator.next() {
                group.addTask {
                    await Self.analyzeSingleAsset(asset, cache: cache, analysisService: analysisService)
                }
                activeTasks += 1
            }
            
            while let result = try await group.next() {
                activeTasks -= 1
                if let item = result {
                    items.append(item)
                }
                await updateProgress()
                
                if let asset = iterator.next() {
                    group.addTask {
                        await Self.analyzeSingleAsset(asset, cache: cache, analysisService: analysisService)
                    }
                    activeTasks += 1
                }
            }
            
            return items
        }
    }
    
    private nonisolated static func analyzeSingleAsset(_ asset: PHAsset, cache: PhotoAnalysisCache, analysisService: PhotoAnalysisService) async -> MemoryItem? {
        if Task.isCancelled { return nil }
        
        let identifier = asset.localIdentifier
        
        if let cachedResult = await cache.getResult(for: identifier) {
            let score = MemoryScore(asset: asset, analysis: cachedResult)
            
            print("Asset:", identifier)
            print("Faces:", cachedResult.faceCount)
            print("Included:", cachedResult.faceCount > 0)
            
            return MemoryItem(asset: asset, score: score)
        }
        
        do {
            let faceCount = try await analysisService.analyzeFaces(in: asset)
            
            print("Asset:", identifier)
            print("Faces:", faceCount)
            print("Included:", faceCount > 0)
            
            let result = PhotoAnalysisResult(
                assetIdentifier: identifier,
                faceCount: faceCount,
                containsPerson: faceCount > 0,
                analyzedAt: Date()
            )
            
            await cache.saveResult(result)
            let score = MemoryScore(asset: asset, analysis: result)
            return MemoryItem(asset: asset, score: score)
        } catch {
            print("Failed to analyze asset \(identifier): \(error)")
            return nil
        }
    }
}
