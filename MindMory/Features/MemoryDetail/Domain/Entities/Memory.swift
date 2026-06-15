import Foundation

enum MemoryImageSource: Equatable {
    case assetLocalIdentifier(String)
    case debugImageURL(URL)
    case assetName(String)
    case placeholder
}

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

    var imageSource: MemoryImageSource {
        imageName.isEmpty ? .placeholder : .assetName(imageName)
    }
}
