import Foundation

enum MemoryAlbumSectionType: String, Equatable, Codable {
    case image
    case text
}

enum MemoryAlbumTextBlockType: String, CaseIterable, Identifiable, Equatable, Codable {
    case titleOnly
    case titleAndDescription
    case descriptionOnly

    var id: Self { self }

    var label: String {
        switch self {
        case .titleOnly:
            return "Title Only"
        case .titleAndDescription:
            return "Title + Description"
        case .descriptionOnly:
            return "Description Only"
        }
    }
}

enum MemoryAlbumTextHorizontalAlignment: String, CaseIterable, Identifiable, Equatable, Codable {
    case leading
    case center
    case trailing

    var id: Self { self }

    var label: String {
        rawValue.capitalized
    }
}

enum MemoryAlbumTextVerticalAlignment: String, CaseIterable, Identifiable, Equatable, Codable {
    case top
    case center
    case bottom

    var id: Self { self }

    var label: String {
        rawValue.capitalized
    }
}

enum MemoryAlbumTextWeight: String, CaseIterable, Identifiable, Equatable, Codable {
    case regular
    case medium
    case semibold
    case bold

    var id: Self { self }

    var label: String {
        rawValue.capitalized
    }
}

struct MemoryAlbumTextStyle: Equatable, Codable {
    var titleSize: Double
    var descriptionSize: Double
    var titleWeight: MemoryAlbumTextWeight
    var descriptionWeight: MemoryAlbumTextWeight

    static let `default` = MemoryAlbumTextStyle(
        titleSize: 28,
        descriptionSize: 16,
        titleWeight: .semibold,
        descriptionWeight: .regular
    )
}

struct MemoryAlbumTextSection: Equatable, Codable {
    let templateVariant: Int
    let blockType: MemoryAlbumTextBlockType
    let horizontalAlignment: MemoryAlbumTextHorizontalAlignment
    let verticalAlignment: MemoryAlbumTextVerticalAlignment
    let isTitleFirst: Bool
    let title: String
    let description: String
    let style: MemoryAlbumTextStyle

    init(
        templateVariant: Int,
        blockType: MemoryAlbumTextBlockType,
        horizontalAlignment: MemoryAlbumTextHorizontalAlignment,
        verticalAlignment: MemoryAlbumTextVerticalAlignment,
        isTitleFirst: Bool,
        title: String,
        description: String,
        style: MemoryAlbumTextStyle
    ) {
        self.templateVariant = templateVariant
        self.blockType = blockType
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.isTitleFirst = isTitleFirst
        self.title = title
        self.description = description
        self.style = style
    }
}

enum MemoryAlbumSectionContent: Equatable, Codable {
    case image(layoutCount: Int, layoutVariant: Int, photos: [AlbumPhoto?])
    case text(MemoryAlbumTextSection)

    private enum CodingKeys: String, CodingKey {
        case type
        case layoutCount
        case layoutVariant
        case photos
        case textSection
    }

    private enum ContentType: String, Codable {
        case image
        case text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)

        switch type {
        case .image:
            let layoutCount = try container.decode(Int.self, forKey: .layoutCount)
            let layoutVariant = try container.decode(Int.self, forKey: .layoutVariant)
            var photos = try container.decode([AlbumPhoto?].self, forKey: .photos)
            if photos.count < layoutCount {
                photos.append(contentsOf: Array(repeating: nil, count: layoutCount - photos.count))
            } else if photos.count > layoutCount {
                photos = Array(photos.prefix(layoutCount))
            }
            self = .image(layoutCount: layoutCount, layoutVariant: layoutVariant, photos: photos)
        case .text:
            let textSection = try container.decode(MemoryAlbumTextSection.self, forKey: .textSection)
            self = .text(textSection)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .image(let layoutCount, let layoutVariant, let photos):
            try container.encode(ContentType.image, forKey: .type)
            try container.encode(layoutCount, forKey: .layoutCount)
            try container.encode(layoutVariant, forKey: .layoutVariant)
            try container.encode(photos, forKey: .photos)
        case .text(let textSection):
            try container.encode(ContentType.text, forKey: .type)
            try container.encode(textSection, forKey: .textSection)
        }
    }
}

struct MemoryAlbumSection: Identifiable, Equatable, Codable {
    let id: UUID
    let content: MemoryAlbumSectionContent

    init(id: UUID = UUID(), layoutCount: Int, layoutVariant: Int = 0, photos: [AlbumPhoto?] = []) {
        self.id = id
        var normalizedPhotos = photos
        if normalizedPhotos.count < layoutCount {
            normalizedPhotos.append(contentsOf: Array(repeating: nil, count: layoutCount - normalizedPhotos.count))
        } else if normalizedPhotos.count > layoutCount {
            normalizedPhotos = Array(normalizedPhotos.prefix(layoutCount))
        }
        self.content = .image(layoutCount: layoutCount, layoutVariant: layoutVariant, photos: normalizedPhotos)
    }

    init(id: UUID = UUID(), textSection: MemoryAlbumTextSection) {
        self.id = id
        self.content = .text(textSection)
    }

    init(id: UUID = UUID(), content: MemoryAlbumSectionContent) {
        self.id = id
        self.content = content
    }

    var type: MemoryAlbumSectionType {
        switch content {
        case .image:
            return .image
        case .text:
            return .text
        }
    }

    var layoutCount: Int? {
        guard case .image(let layoutCount, _, _) = content else { return nil }
        return layoutCount
    }

    var layoutVariant: Int? {
        guard case .image(_, let layoutVariant, _) = content else { return nil }
        return layoutVariant
    }

    var photos: [AlbumPhoto?] {
        guard case .image(_, _, let photos) = content else { return [] }
        return photos
    }

    var textSection: MemoryAlbumTextSection? {
        guard case .text(let textSection) = content else { return nil }
        return textSection
    }
}
