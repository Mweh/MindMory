import Foundation

struct Memory: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let dateText: String
    let locationName: String?
    let imageName: String
    var journalText: String?
    var isFavorite: Bool
    let tags: [String]
}
