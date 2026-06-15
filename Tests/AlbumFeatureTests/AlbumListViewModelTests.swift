import XCTest
@testable import MindMory

final class AlbumListViewModelTests: XCTestCase {
    class InMemoryAlbumRepository: AlbumRepositoryProtocol {
        private var storage: [Album]

        init(initial: [Album] = []) {
            self.storage = initial
        }

        func fetchAlbums() async throws -> [Album] {
            return storage.sorted { $0.createdAt > $1.createdAt }
        }

        func save(_ album: Album) async throws {
            if let index = storage.firstIndex(where: { $0.id == album.id }) {
                storage[index] = album
            } else {
                storage.insert(album, at: 0)
            }
        }

        func deleteAlbum(id: UUID) async throws {
            storage.removeAll { $0.id == id }
        }
    }

    func testLoadAlbums_updatesAlbums() async throws {
        let sample = PreviewData.sampleAlbums
        let repo = InMemoryAlbumRepository(initial: sample)
        let vm = AlbumListViewModel()
        vm.configure(repository: repo)

        // wait for the asynchronous load to finish
        let deadline = Date().addingTimeInterval(2.0)
        while vm.isLoading && Date() < deadline {
            try await Task.sleep(nanoseconds: 50_000_000)
        }

        XCTAssertEqual(vm.albums.count, sample.count)
    }

    func testAddAlbum_persists() async throws {
        let repo = InMemoryAlbumRepository(initial: [])
        let vm = AlbumListViewModel()
        vm.configure(repository: repo)

        let photo = AlbumPhoto(id: UUID(), imageData: Data([0x00]))
        let album = Album(id: UUID(), name: "Test", note: "", photos: [photo], sections: [], createdAt: Date(), category: .memory)

        vm.addAlbum(album)

        // allow save task to complete
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(vm.albums.contains { $0.id == album.id })
    }

    func testRemoveAlbum_rollsBackOnError() async throws {
        class FailingRepo: InMemoryAlbumRepository {
            override func deleteAlbum(id: UUID) async throws {
                throw NSError(domain: "Test", code: 1)
            }
        }

        let photo = AlbumPhoto(id: UUID(), imageData: Data([0x00]))
        let album = Album(id: UUID(), name: "ToDelete", note: "", photos: [photo], sections: [], createdAt: Date(), category: .memory)
        let repo = FailingRepo(initial: [album])
        let vm = AlbumListViewModel()
        vm.configure(repository: repo)

        // wait for initial load
        let deadline = Date().addingTimeInterval(2.0)
        while vm.isLoading && Date() < deadline {
            try await Task.sleep(nanoseconds: 50_000_000)
        }

        vm.removeAlbum(id: album.id)
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(vm.albums.contains { $0.id == album.id })
    }
}
