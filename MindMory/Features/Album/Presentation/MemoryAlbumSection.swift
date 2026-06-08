import Foundation

enum MemoryAlbumSectionType: String, Equatable {
    case image
    case text
}

enum MemoryAlbumTextBlockType: String, CaseIterable, Identifiable, Equatable {
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

enum MemoryAlbumTextHorizontalAlignment: String, CaseIterable, Identifiable, Equatable {
    case leading
    case center
    case trailing

    var id: Self { self }

    var label: String {
        rawValue.capitalized
    }
}

enum MemoryAlbumTextVerticalAlignment: String, CaseIterable, Identifiable, Equatable {
    case top
    case center
    case bottom

    var id: Self { self }

    var label: String {
        rawValue.capitalized
    }
}

enum MemoryAlbumTextWeight: String, CaseIterable, Identifiable, Equatable {
    case regular
    case medium
    case semibold
    case bold

    var id: Self { self }

    var label: String {
        rawValue.capitalized
    }
}

struct MemoryAlbumTextStyle: Equatable {
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

struct MemoryAlbumTextSection: Equatable {
    let templateVariant: Int
    let blockType: MemoryAlbumTextBlockType
    let horizontalAlignment: MemoryAlbumTextHorizontalAlignment
    let verticalAlignment: MemoryAlbumTextVerticalAlignment
    let isTitleFirst: Bool
    let title: String
    let description: String
    let style: MemoryAlbumTextStyle
}

enum MemoryAlbumSectionContent: Equatable {
    case image(layoutCount: Int, layoutVariant: Int, photos: [AlbumPhoto?])
    case text(MemoryAlbumTextSection)
}

struct MemoryAlbumSection: Identifiable, Equatable {
    let id: UUID
    let content: MemoryAlbumSectionContent

    init(id: UUID = UUID(), layoutCount: Int, layoutVariant: Int = 0, photos: [AlbumPhoto?] = []) {
        self.id = id
        self.content = .image(layoutCount: layoutCount, layoutVariant: layoutVariant, photos: photos)
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
