import Foundation

enum AlbumCategory: String, Codable {
    case timeline
    case memory
}

struct Album: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let note: String
    let photos: [AlbumPhoto]
    let sections: [MemoryAlbumSection]
    let createdAt: Date
    let category: AlbumCategory

    var coverPhoto: AlbumPhoto? {
        photos.first
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
