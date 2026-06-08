import Foundation

enum AlbumCategory: String, Codable {
    case timeline
    case memory
}

struct Album: Identifiable, Equatable {
    let id: UUID
    let name: String
    let note: String
    let photos: [AlbumPhoto]
    let createdAt: Date
    let category: AlbumCategory
}
