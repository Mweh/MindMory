import Foundation
import SwiftData

protocol AlbumRepositoryProtocol {
    func fetchAlbums() -> [Album]
    func save(_ album: Album) throws
    func deleteAlbum(id: UUID) throws
}

@MainActor
final class AlbumRepository: AlbumRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAlbums() -> [Album] {
        let fetchDescriptor = FetchDescriptor<AlbumEntity>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let entities = (try? context.fetch(fetchDescriptor)) ?? []
        return entities.compactMap { entity in
            try? entity.toDomain()
        }
    }

    func save(_ album: Album) throws {
        let encoded = try JSONEncoder().encode(album)

        if let existingEntity = try context.fetch(FetchDescriptor<AlbumEntity>()).first(where: { $0.id == album.id }) {
            existingEntity.payload = encoded
            existingEntity.createdAt = album.createdAt
        } else {
            context.insert(AlbumEntity(id: album.id, createdAt: album.createdAt, payload: encoded))
        }

        try context.save()
    }

    func deleteAlbum(id: UUID) throws {
        let fetchDescriptor = FetchDescriptor<AlbumEntity>()
        guard let entity = try context.fetch(fetchDescriptor).first(where: { $0.id == id }) else { return }
        context.delete(entity)
        try context.save()
    }
}

@Model
final class AlbumEntity: Identifiable {
    var id: UUID
    var createdAt: Date
    var payload: Data

    init(id: UUID = UUID(), createdAt: Date = Date(), payload: Data) {
        self.id = id
        self.createdAt = createdAt
        self.payload = payload
    }

    func toDomain() throws -> Album {
        try JSONDecoder().decode(Album.self, from: payload)
    }
}
