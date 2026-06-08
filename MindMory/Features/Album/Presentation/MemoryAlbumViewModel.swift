import Combine
import UIKit

final class MemoryAlbumViewModel: AlbumCreationViewModel {
    @Published private(set) var sections: [MemoryAlbumSection] = []

    init(
        loadAlbumPhotosUseCase: LoadAlbumPhotosUseCase = LoadAlbumPhotosUseCase(),
        createAlbumUseCase: CreateAlbumUseCase = CreateAlbumUseCase()
    ) {
        super.init(category: .memory, loadAlbumPhotosUseCase: loadAlbumPhotosUseCase, createAlbumUseCase: createAlbumUseCase)
    }

    func addSection(_ section: MemoryAlbumSection) {
        sections.append(section)
    }

    func updateSectionPhoto(sectionId: UUID, index: Int, photo: AlbumPhoto) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionId }) else { return }

        let section = sections[sectionIndex]
        guard case .image(let layoutCount, let layoutVariant, var photos) = section.content else { return }

        if photos.count != layoutCount {
            photos = Array(repeating: nil, count: layoutCount)
        }
        guard photos.indices.contains(index) else { return }
        photos[index] = photo

        sections[sectionIndex] = MemoryAlbumSection(
            id: section.id,
            content: .image(layoutCount: layoutCount, layoutVariant: layoutVariant, photos: photos)
        )
    }

    func moveSection(sourceId: UUID, destinationId: UUID) {
        guard sourceId != destinationId else { return }
        guard let sourceIndex = sections.firstIndex(where: { $0.id == sourceId }) else { return }
        guard let destinationIndex = sections.firstIndex(where: { $0.id == destinationId }) else { return }

        var reordered = sections
        let movingSection = reordered.remove(at: sourceIndex)
        let adjustedIndex = sourceIndex < destinationIndex ? destinationIndex - 1 : destinationIndex
        reordered.insert(movingSection, at: adjustedIndex)
        sections = reordered
    }

    func moveSectionToTop(sourceId: UUID) {
        guard let sourceIndex = sections.firstIndex(where: { $0.id == sourceId }) else { return }
        guard sourceIndex != 0 else { return }

        var reordered = sections
        let movingSection = reordered.remove(at: sourceIndex)
        reordered.insert(movingSection, at: 0)
        sections = reordered
    }

    func moveSectionToBottom(sourceId: UUID) {
        guard let sourceIndex = sections.firstIndex(where: { $0.id == sourceId }) else { return }
        guard sourceIndex != sections.count - 1 else { return }

        var reordered = sections
        let movingSection = reordered.remove(at: sourceIndex)
        reordered.append(movingSection)
        sections = reordered
    }

    var hasIncompleteSections: Bool {
        sections.contains { section in
            guard case .image(let layoutCount, _, let photos) = section.content else { return false }
            guard photos.count == layoutCount else { return true }
            return photos.contains(where: { $0 == nil })
        }
    }

    override func saveAlbum() {
        do {
            var albumPhotos = [AlbumPhoto]()
            if let coverPhoto = coverPhoto {
                albumPhotos.append(coverPhoto)
            }

            let sectionPhotos = sections.reduce(into: [AlbumPhoto]()) { result, section in
                guard case .image(_, _, let photos) = section.content else { return }
                result.append(contentsOf: photos.compactMap { $0 })
            }
            albumPhotos.append(contentsOf: sectionPhotos)

            let album = try createAlbumUseCase.execute(
                name: albumName,
                note: note,
                photos: albumPhotos,
                category: category
            )

            savedAlbum = album
            presentAlert("\(album.name) is ready. Your album has been created.")
        } catch {
            presentAlert(error.localizedDescription)
        }
    }
}
