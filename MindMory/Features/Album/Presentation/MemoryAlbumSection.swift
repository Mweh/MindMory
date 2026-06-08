import SwiftUI
import Foundation

enum MemoryAlbumSectionType: String, Equatable {
    case image
    case text
    case shape
}

enum MemoryAlbumShapeType: String, CaseIterable, Identifiable, Equatable {
    case rectangle
    case roundedRectangle
    case circle
    case capsule
    case diamond

    var id: Self { self }
    var label: String {
        switch self {
        case .rectangle:
            return "Rectangle"
        case .roundedRectangle:
            return "Rounded"
        case .circle:
            return "Circle"
        case .capsule:
            return "Capsule"
        case .diamond:
            return "Diamond"
        }
    }
}

enum MemoryAlbumShapeBlendMode: String, CaseIterable, Identifiable, Equatable {
    case normal
    case multiply
    case overlay
    case screen

    var id: Self { self }
    var label: String {
        switch self {
        case .normal:
            return "Normal"
        case .multiply:
            return "Multiply"
        case .overlay:
            return "Overlay"
        case .screen:
            return "Screen"
        }
    }
}

struct MemoryAlbumShapeStyle: Equatable {
    let fillHex: String
    let borderHex: String
    let borderWidth: Double
    let opacity: Double
    let blendMode: MemoryAlbumShapeBlendMode

    static let `default` = MemoryAlbumShapeStyle(
        fillHex: "3B82F6",
        borderHex: "FFFFFF",
        borderWidth: 2,
        opacity: 1,
        blendMode: .normal
    )

    var fillColor: Color {
        Color(hex: fillHex)
    }

    var borderColor: Color {
        Color(hex: borderHex)
    }
}

struct MemoryAlbumShapeSection: Equatable {
    let type: MemoryAlbumShapeType
    let style: MemoryAlbumShapeStyle
    let offset: CGSize
    let scale: CGFloat

    init(type: MemoryAlbumShapeType, style: MemoryAlbumShapeStyle, offset: CGSize = .zero, scale: CGFloat = 1) {
        self.type = type
        self.style = style
        self.offset = offset
        self.scale = scale
    }
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
    let isAdaptive: Bool
    let offset: CGSize
    let scale: CGFloat

    init(
        templateVariant: Int,
        blockType: MemoryAlbumTextBlockType,
        horizontalAlignment: MemoryAlbumTextHorizontalAlignment,
        verticalAlignment: MemoryAlbumTextVerticalAlignment,
        isTitleFirst: Bool,
        title: String,
        description: String,
        style: MemoryAlbumTextStyle,
        isAdaptive: Bool = false,
        offset: CGSize = .zero,
        scale: CGFloat = 1
    ) {
        self.templateVariant = templateVariant
        self.blockType = blockType
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.isTitleFirst = isTitleFirst
        self.title = title
        self.description = description
        self.style = style
        self.isAdaptive = isAdaptive
        self.offset = offset
        self.scale = scale
    }
}

enum MemoryAlbumSectionContent: Equatable {
    case image(layoutCount: Int, layoutVariant: Int, photos: [AlbumPhoto?])
    case text(MemoryAlbumTextSection)
    case shape(MemoryAlbumShapeSection)
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
        case .shape:
            return .shape
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

    var shapeSection: MemoryAlbumShapeSection? {
        guard case .shape(let shapeSection) = content else { return nil }
        return shapeSection
    }
}
