import Combine
import Foundation

final class AlbumListViewModel: ObservableObject {
    @Published private(set) var albums: [Album]

    init(albums: [Album] = []) {
        self.albums = albums
    }

    func addAlbum(_ album: Album) {
        albums.insert(album, at: 0)
    }

    func removeAlbum(id: UUID) {
        albums.removeAll { $0.id == id }
    }
}
