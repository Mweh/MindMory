import Foundation

enum AlbumCategory: String, Codable {
    case timeline
    case memory
}

struct AlbumDate: Equatable {
    let start: Date
    let end: Date

    var isSingleDay: Bool {
        Calendar.current.isDate(start, inSameDayAs: end)
    }

    var displayText: String {
        if isSingleDay {
            return start.formatted(date: .abbreviated, time: .omitted)
        }

        let startText = start.formatted(date: .abbreviated, time: .omitted)
        let endText = end.formatted(date: .abbreviated, time: .omitted)
        return "\(startText) – \(endText)"
    }
}

struct Album: Identifiable, Equatable {
    let id: UUID
    let name: String
    let note: String
    let photos: [AlbumPhoto]
    let sections: [MemoryAlbumSection]
    let albumDate: AlbumDate
    let createdAt: Date
    let category: AlbumCategory

    var coverPhoto: AlbumPhoto? {
        photos.first
    }
}
