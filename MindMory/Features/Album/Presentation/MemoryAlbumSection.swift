import SwiftUI
import Foundation

enum MemoryAlbumSectionType: String, Equatable {
    case image
    case text
    case base
}

enum MemoryAlbumSectionCellContent: Equatable {
    case placeholder
    case image(AlbumPhoto)
    case text(MemoryAlbumTextSection)
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

enum MemoryAlbumSectionContent: Equatable {
    case image(layoutCount: Int, layoutVariant: Int, photos: [AlbumPhoto?])
    case text(MemoryAlbumTextSection)
    case base(layoutCount: Int, layoutVariant: Int, cells: [MemoryAlbumSectionCellContent])
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

    init(id: UUID = UUID(), baseLayoutCount: Int, layoutVariant: Int = 0, cells: [MemoryAlbumSectionCellContent] = []) {
        self.id = id
        self.content = .base(layoutCount: baseLayoutCount, layoutVariant: layoutVariant, cells: cells)
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
        case .base:
            return .base
        }
    }

    var layoutCount: Int? {
        switch content {
        case .image(let layoutCount, _, _), .base(let layoutCount, _, _):
            return layoutCount
        default:
            return nil
        }
    }

    var layoutVariant: Int? {
        switch content {
        case .image(_, let layoutVariant, _), .base(_, let layoutVariant, _):
            return layoutVariant
        default:
            return nil
        }
    }

    var photos: [AlbumPhoto?] {
        guard case .image(_, _, let photos) = content else { return [] }
        return photos
    }

    var baseCells: [MemoryAlbumSectionCellContent] {
        guard case .base(_, _, let cells) = content else { return [] }
        return cells
    }

    var textSection: MemoryAlbumTextSection? {
        guard case .text(let textSection) = content else { return nil }
        return textSection
    }
}
