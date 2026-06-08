import Foundation

enum CreateAlbumError: LocalizedError {
    case emptyName
    case noPhotos

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Please enter an album name before saving."
        case .noPhotos:
            return "Select at least one photo from your gallery."
        }
    }
}

struct CreateAlbumUseCase {
    func execute(name: String, note: String, photos: [AlbumPhoto], sections: [MemoryAlbumSection] = [], category: AlbumCategory) throws -> Album {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            throw CreateAlbumError.emptyName
        }

        guard !photos.isEmpty else {
            throw CreateAlbumError.noPhotos
        }

        return Album(
            id: UUID(),
            name: trimmedName,
            note: note,
            photos: photos,
            sections: sections,
            createdAt: Date(),
            category: category
        )
    }
}
