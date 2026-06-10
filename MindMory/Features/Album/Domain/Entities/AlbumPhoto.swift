import Foundation

struct AlbumPhoto: Identifiable, Codable, Equatable {
    let id: UUID
    let imageData: Data
}
