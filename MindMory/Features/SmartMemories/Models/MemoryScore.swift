import Foundation
import Photos

public struct MemoryScore: Comparable {
    public let faceCount: Int
    public let isFavorite: Bool
    public let creationDate: Date
    public let hasLocation: Bool
    public let containsPerson: Bool
    
    public var relevanceScore: Int {
        var score = 0
        score += faceCount * 10
        score += isFavorite ? 50 : 0
        score += hasLocation ? 10 : 0
        score += containsPerson ? 20 : 0
        return score
    }
    
    public init(asset: PHAsset, analysis: PhotoAnalysisResult) {
        self.faceCount = analysis.faceCount
        self.isFavorite = asset.isFavorite
        self.creationDate = asset.creationDate ?? Date.distantPast
        self.hasLocation = asset.location != nil
        self.containsPerson = analysis.containsPerson
    }
    
    public static func < (lhs: MemoryScore, rhs: MemoryScore) -> Bool {
        if lhs.relevanceScore != rhs.relevanceScore {
            return lhs.relevanceScore < rhs.relevanceScore
        }
        return lhs.creationDate < rhs.creationDate
    }
}
