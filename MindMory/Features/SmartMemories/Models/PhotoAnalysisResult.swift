import Foundation

public struct PhotoAnalysisResult: Codable, Equatable, Sendable {
    public let assetIdentifier: String
    public let faceCount: Int
    public let containsPerson: Bool
    public let analyzedAt: Date
    
    public init(assetIdentifier: String, faceCount: Int, containsPerson: Bool, analyzedAt: Date) {
        self.assetIdentifier = assetIdentifier
        self.faceCount = faceCount
        self.containsPerson = containsPerson
        self.analyzedAt = analyzedAt
    }
}
