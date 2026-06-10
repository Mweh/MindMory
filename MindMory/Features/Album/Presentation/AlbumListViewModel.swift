import Foundation
import Combine

@MainActor
final class AlbumListViewModel: ObservableObject {
    @Published private(set) var albums: [Album] = []

    private var repository: AlbumRepositoryProtocol?
    private var hasLoadedAlbums = false

    init(albums: [Album] = [], repository: AlbumRepositoryProtocol? = nil) {
        self.albums = albums
        self.repository = repository
    }

    func configure(repository: AlbumRepositoryProtocol) {
        guard self.repository == nil else { return }
        self.repository = repository
        loadAlbumsIfNeeded()
    }

    func loadAlbumsIfNeeded() {
        guard !hasLoadedAlbums else { return }
        hasLoadedAlbums = true
        loadAlbums()
    }

    func loadAlbums() {
        guard let repository = repository else { return }
        albums = repository.fetchAlbums()
    }

    func addAlbum(_ album: Album) {
        albums.insert(album, at: 0)

        Task {
            try? repository?.save(album)
        }
    }

    func removeAlbum(id: UUID) {
        albums.removeAll { $0.id == id }

        Task {
            try? repository?.deleteAlbum(id: id)
        }
    }
}
