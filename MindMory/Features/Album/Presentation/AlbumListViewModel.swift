import Foundation
import Combine

@MainActor
final class AlbumListViewModel: ObservableObject {
    @Published private(set) var albums: [Album] = []
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String?

    private var repository: AlbumRepositoryProtocol?
    private var hasLoadedAlbums = false

    init(albums: [Album] = [], repository: AlbumRepositoryProtocol? = nil) {
        self.albums = albums
        self.repository = repository
    }

    func configure(repository: AlbumRepositoryProtocol) {
        guard self.repository == nil else { return }
        self.repository = repository
        isLoading = true
        Task { await loadAlbumsIfNeeded() }
    }

    func loadAlbumsIfNeeded() async {
        guard !hasLoadedAlbums else { isLoading = false; return }
        await loadAlbums()
    }

    func reloadAlbums() {
        hasLoadedAlbums = false
        isLoading = true
        Task { await loadAlbumsIfNeeded() }
    }

    private func loadAlbums() async {
        guard let repository = repository else { isLoading = false; return }
        isLoading = true
        defer { isLoading = false }

        // Fetching from repository is actor-isolated; call directly on MainActor
        do {
            let fetched = try await repository.fetchAlbums()
            albums = fetched
            hasLoadedAlbums = true
        } catch {
            albums = []
            alertMessage = error.localizedDescription
        }
    }

    func addAlbum(_ album: Album) {
        // Optimistic UI update then persist; rollback on failure
        albums.insert(album, at: 0)

        Task { [weak self] in
            guard let self = self, let repository = self.repository else { return }
            do {
                try await repository.save(album)
            } catch {
                await MainActor.run {
                    self.albums.removeAll { $0.id == album.id }
                    self.alertMessage = error.localizedDescription
                }
            }
        }
    }

    func updateAlbum(_ album: Album) {
        guard let index = albums.firstIndex(where: { $0.id == album.id }) else { return }
        let previous = albums[index]
        albums[index] = album

        Task { [weak self] in
            guard let self = self, let repository = self.repository else { return }
            do {
                try await repository.save(album)
            } catch {
                await MainActor.run {
                    self.albums[index] = previous
                    self.alertMessage = error.localizedDescription
                }
            }
        }
    }

    func removeAlbum(id: UUID) {
        let removed = albums.filter { $0.id == id }
        albums.removeAll { $0.id == id }

        Task { [weak self] in
            guard let self = self, let repository = self.repository else { return }
            do {
                try await repository.deleteAlbum(id: id)
            } catch {
                await MainActor.run {
                    // rollback
                    self.albums.insert(contentsOf: removed, at: 0)
                    self.alertMessage = error.localizedDescription
                }
            }
        }
    }

    func dismissAlert() {
        alertMessage = nil
    }
}
