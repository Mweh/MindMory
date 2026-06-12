import Foundation

struct AlbumPhoto: Identifiable, Codable, Equatable {
    let id: UUID
    let imageData: Data
}

extension AlbumPhoto {
    nonisolated static func == (lhs: AlbumPhoto, rhs: AlbumPhoto) -> Bool {
        return lhs.id == rhs.id && lhs.imageData == rhs.imageData
    }
}
