import SwiftUI

enum MemoryAlbumSectionSplitAxis {
    case horizontal
    case vertical
}

indirect enum MemoryAlbumSectionLayoutNode {
    case photo(index: Int)
    case spacer
    case split(
        axis: MemoryAlbumSectionSplitAxis,
        children: [MemoryAlbumSectionLayoutNode],
        weights: [CGFloat],
        spacing: CGFloat
    )
}

struct MemoryAlbumSectionLayoutTemplate: Identifiable {
    let layoutCount: Int
    let variant: Int
    let title: String
    let subtitle: String
    let selectionHeight: CGFloat
    let albumHeight: CGFloat
    let contentInset: CGFloat
    let node: MemoryAlbumSectionLayoutNode

    var id: Int { variant }
}

enum MemoryAlbumSectionLayoutCatalog {
    static func templates(for layoutCount: Int) -> [MemoryAlbumSectionLayoutTemplate] {
        switch layoutCount {
        case 1:
            return onePhotoTemplates
        case 2:
            return twoPhotoTemplates
        case 3:
            return threePhotoTemplates
        case 4:
            return fourPhotoTemplates
        case 5:
            return fivePhotoTemplates
        default:
            return onePhotoTemplates
        }
    }

    static func template(layoutCount: Int, variant: Int) -> MemoryAlbumSectionLayoutTemplate {
        let options = templates(for: layoutCount)

        if let match = options.first(where: { $0.variant == variant }) {
            return match
        }

        return options.first ?? onePhotoTemplates[0]
    }

    private static let onePhotoTemplates: [MemoryAlbumSectionLayoutTemplate] = [
        .init(layoutCount: 1, variant: 0, title: "Full Frame", subtitle: "Edge-to-edge single photo", selectionHeight: 220, albumHeight: 260, contentInset: 0, node: .photo(index: 0)),
        .init(layoutCount: 1, variant: 1, title: "Soft Inset", subtitle: "Breathing room around photo", selectionHeight: 220, albumHeight: 260, contentInset: MindMorySpacing.sm, node: .photo(index: 0)),
        .init(layoutCount: 1, variant: 2, title: "Wide Hero", subtitle: "Landscape-first composition", selectionHeight: 180, albumHeight: 210, contentInset: 0, node: .photo(index: 0)),
        .init(layoutCount: 1, variant: 3, title: "Tall Hero", subtitle: "Portrait-first composition", selectionHeight: 280, albumHeight: 320, contentInset: 0, node: .photo(index: 0)),
        .init(layoutCount: 1, variant: 4, title: "Postcard", subtitle: "Centered postcard feeling", selectionHeight: 210, albumHeight: 245, contentInset: MindMorySpacing.md, node: .photo(index: 0)),
        .init(layoutCount: 1, variant: 5, title: "Minimal Strip", subtitle: "Compact single photo", selectionHeight: 170, albumHeight: 195, contentInset: MindMorySpacing.lg, node: .photo(index: 0))
    ]

    private static let twoPhotoTemplates: [MemoryAlbumSectionLayoutTemplate] = [
        .init(layoutCount: 2, variant: 0, title: "Split Vertical", subtitle: "Two columns", selectionHeight: 180, albumHeight: 220, contentInset: 0, node: row([.photo(index: 0), .photo(index: 1)])),
        .init(layoutCount: 2, variant: 1, title: "Split Horizontal", subtitle: "Two stacked rows", selectionHeight: 220, albumHeight: 260, contentInset: 0, node: column([.photo(index: 0), .photo(index: 1)])),
        .init(layoutCount: 2, variant: 2, title: "Lead Left", subtitle: "Wide left, narrow right", selectionHeight: 190, albumHeight: 235, contentInset: 0, node: row([.photo(index: 0), .photo(index: 1)], weights: [1.65, 1])),
        .init(layoutCount: 2, variant: 3, title: "Lead Right", subtitle: "Narrow left, wide right", selectionHeight: 190, albumHeight: 235, contentInset: 0, node: row([.photo(index: 0), .photo(index: 1)], weights: [1, 1.65])),
        .init(layoutCount: 2, variant: 4, title: "Top Focus", subtitle: "Large top, compact bottom", selectionHeight: 240, albumHeight: 280, contentInset: 0, node: column([.photo(index: 0), .photo(index: 1)], weights: [1.65, 1])),
        .init(layoutCount: 2, variant: 5, title: "Bottom Focus", subtitle: "Compact top, large bottom", selectionHeight: 240, albumHeight: 280, contentInset: 0, node: column([.photo(index: 0), .photo(index: 1)], weights: [1, 1.65])),
        .init(layoutCount: 2, variant: 6, title: "Narrow Gutter", subtitle: "Tight side-by-side", selectionHeight: 180, albumHeight: 220, contentInset: MindMorySpacing.xs, node: row([.photo(index: 0), .photo(index: 1)], spacing: MindMorySpacing.xxs)),
        .init(layoutCount: 2, variant: 7, title: "Airy Stack", subtitle: "Large spacing between rows", selectionHeight: 230, albumHeight: 270, contentInset: MindMorySpacing.xs, node: column([.photo(index: 0), .photo(index: 1)], spacing: MindMorySpacing.md)),
        .init(layoutCount: 2, variant: 8, title: "Editorial Pair", subtitle: "Inset and balanced columns", selectionHeight: 190, albumHeight: 230, contentInset: MindMorySpacing.md, node: row([.photo(index: 0), .photo(index: 1)])),
        .init(layoutCount: 2, variant: 9, title: "Story Pair", subtitle: "Inset stacked narrative", selectionHeight: 235, albumHeight: 275, contentInset: MindMorySpacing.md, node: column([.photo(index: 0), .photo(index: 1)]))
    ]

    private static let threePhotoTemplates: [MemoryAlbumSectionLayoutTemplate] = [
        .init(layoutCount: 3, variant: 0, title: "Feature Left", subtitle: "Large left + two right", selectionHeight: 220, albumHeight: 265, contentInset: 0, node: row([.photo(index: 0), column([.photo(index: 1), .photo(index: 2)])], weights: [1.45, 1])),
        .init(layoutCount: 3, variant: 1, title: "Feature Right", subtitle: "Two left + large right", selectionHeight: 220, albumHeight: 265, contentInset: 0, node: row([column([.photo(index: 0), .photo(index: 1)]), .photo(index: 2)], weights: [1, 1.45])),
        .init(layoutCount: 3, variant: 2, title: "Bottom Banner", subtitle: "Two top + one wide bottom", selectionHeight: 240, albumHeight: 280, contentInset: 0, node: column([row([.photo(index: 0), .photo(index: 1)]), .photo(index: 2)], weights: [1, 1.2])),
        .init(layoutCount: 3, variant: 3, title: "Top Banner", subtitle: "One wide top + two bottom", selectionHeight: 240, albumHeight: 280, contentInset: 0, node: column([.photo(index: 0), row([.photo(index: 1), .photo(index: 2)])], weights: [1.2, 1])),
        .init(layoutCount: 3, variant: 4, title: "Triple Vertical", subtitle: "Three equal columns", selectionHeight: 175, albumHeight: 215, contentInset: 0, node: row([.photo(index: 0), .photo(index: 1), .photo(index: 2)])),
        .init(layoutCount: 3, variant: 5, title: "Triple Horizontal", subtitle: "Three equal rows", selectionHeight: 270, albumHeight: 310, contentInset: 0, node: column([.photo(index: 0), .photo(index: 1), .photo(index: 2)])),
        .init(layoutCount: 3, variant: 6, title: "Center Emphasis", subtitle: "Wide center column", selectionHeight: 180, albumHeight: 220, contentInset: 0, node: row([.photo(index: 0), .photo(index: 1), .photo(index: 2)], weights: [1, 1.5, 1])),
        .init(layoutCount: 3, variant: 7, title: "Center Story", subtitle: "Large middle row", selectionHeight: 250, albumHeight: 290, contentInset: 0, node: column([.photo(index: 0), .photo(index: 1), .photo(index: 2)], weights: [1, 1.5, 1])),
        .init(layoutCount: 3, variant: 8, title: "Compact Feature", subtitle: "Inset featured-left layout", selectionHeight: 220, albumHeight: 255, contentInset: MindMorySpacing.sm, node: row([.photo(index: 0), column([.photo(index: 1), .photo(index: 2)])], weights: [1.35, 1], spacing: MindMorySpacing.xs)),
        .init(layoutCount: 3, variant: 9, title: "Compact Banner", subtitle: "Inset top-banner layout", selectionHeight: 240, albumHeight: 275, contentInset: MindMorySpacing.sm, node: column([.photo(index: 0), row([.photo(index: 1), .photo(index: 2)])], weights: [1.1, 1], spacing: MindMorySpacing.xs))
    ]

    private static let fourPhotoTemplates: [MemoryAlbumSectionLayoutTemplate] = [
        .init(layoutCount: 4, variant: 0, title: "Classic Grid", subtitle: "Two by two", selectionHeight: 250, albumHeight: 290, contentInset: 0, node: column([row([.photo(index: 0), .photo(index: 1)]), row([.photo(index: 2), .photo(index: 3)])])),
        .init(layoutCount: 4, variant: 1, title: "Four Rows", subtitle: "Vertical storyboard", selectionHeight: 320, albumHeight: 360, contentInset: 0, node: column([.photo(index: 0), .photo(index: 1), .photo(index: 2), .photo(index: 3)])),
        .init(layoutCount: 4, variant: 2, title: "Four Columns", subtitle: "Horizontal storyboard", selectionHeight: 165, albumHeight: 205, contentInset: 0, node: row([.photo(index: 0), .photo(index: 1), .photo(index: 2), .photo(index: 3)])),
        .init(layoutCount: 4, variant: 3, title: "Lead + Trio", subtitle: "Big left + three right rows", selectionHeight: 260, albumHeight: 300, contentInset: 0, node: row([.photo(index: 0), column([.photo(index: 1), .photo(index: 2), .photo(index: 3)])], weights: [1.35, 1])),
        .init(layoutCount: 4, variant: 4, title: "Trio + Lead", subtitle: "Three left rows + big right", selectionHeight: 260, albumHeight: 300, contentInset: 0, node: row([column([.photo(index: 0), .photo(index: 1), .photo(index: 2)]), .photo(index: 3)], weights: [1, 1.35])),
        .init(layoutCount: 4, variant: 5, title: "Top Hero", subtitle: "Large top + three bottom", selectionHeight: 255, albumHeight: 295, contentInset: 0, node: column([.photo(index: 0), row([.photo(index: 1), .photo(index: 2), .photo(index: 3)])], weights: [1.25, 1])),
        .init(layoutCount: 4, variant: 6, title: "Bottom Hero", subtitle: "Three top + large bottom", selectionHeight: 255, albumHeight: 295, contentInset: 0, node: column([row([.photo(index: 0), .photo(index: 1), .photo(index: 2)]), .photo(index: 3)], weights: [1, 1.25])),
        .init(layoutCount: 4, variant: 7, title: "Magazine Left", subtitle: "Two stacked + mixed right", selectionHeight: 260, albumHeight: 300, contentInset: 0, node: row([column([.photo(index: 0), .photo(index: 1)]), column([.photo(index: 2), .photo(index: 3)], weights: [1.45, 1])], weights: [1, 1.15])),
        .init(layoutCount: 4, variant: 8, title: "Magazine Right", subtitle: "Mixed left + two stacked", selectionHeight: 260, albumHeight: 300, contentInset: 0, node: row([column([.photo(index: 0), .photo(index: 1)], weights: [1.45, 1]), column([.photo(index: 2), .photo(index: 3)])], weights: [1.15, 1])),
        .init(layoutCount: 4, variant: 9, title: "Inset Grid", subtitle: "Grid with clean margins", selectionHeight: 250, albumHeight: 285, contentInset: MindMorySpacing.md, node: column([row([.photo(index: 0), .photo(index: 1)]), row([.photo(index: 2), .photo(index: 3)])], spacing: MindMorySpacing.xs)),
        .init(layoutCount: 4, variant: 10, title: "Gutter Grid", subtitle: "Grid with airy gaps", selectionHeight: 255, albumHeight: 295, contentInset: MindMorySpacing.xs, node: column([row([.photo(index: 0), .photo(index: 1)], spacing: MindMorySpacing.md), row([.photo(index: 2), .photo(index: 3)], spacing: MindMorySpacing.md)], spacing: MindMorySpacing.md)),
        .init(layoutCount: 4, variant: 11, title: "Cascade", subtitle: "Large top + mixed lower row", selectionHeight: 270, albumHeight: 310, contentInset: 0, node: column([.photo(index: 0), row([.photo(index: 1), column([.photo(index: 2), .photo(index: 3)])], weights: [1.25, 1])], weights: [1.15, 1])),
        .init(layoutCount: 4, variant: 12, title: "Stagger Left First", subtitle: "Left column starts higher, equal photo sizes", selectionHeight: 290, albumHeight: 330, contentInset: 0, node: row([
            column([.photo(index: 0), .photo(index: 1), .spacer], weights: [1, 1, 0.38]),
            column([.spacer, .photo(index: 2), .photo(index: 3)], weights: [0.38, 1, 1])
        ])),
        .init(layoutCount: 4, variant: 13, title: "Stagger Right First", subtitle: "Right column starts higher, equal photo sizes", selectionHeight: 290, albumHeight: 330, contentInset: 0, node: row([
            column([.spacer, .photo(index: 0), .photo(index: 1)], weights: [0.38, 1, 1]),
            column([.photo(index: 2), .photo(index: 3), .spacer], weights: [1, 1, 0.38])
        ])),
        .init(layoutCount: 4, variant: 14, title: "Portrait Stagger Left", subtitle: "Left starts higher with portrait-size cells", selectionHeight: 360, albumHeight: 430, contentInset: 0, node: row([
            column([.photo(index: 0), .photo(index: 1), .spacer], weights: [1, 1, 0.3]),
            column([.spacer, .photo(index: 2), .photo(index: 3)], weights: [0.3, 1, 1])
        ])),
        .init(layoutCount: 4, variant: 15, title: "Portrait Stagger Right", subtitle: "Right starts higher with portrait-size cells", selectionHeight: 360, albumHeight: 430, contentInset: 0, node: row([
            column([.spacer, .photo(index: 0), .photo(index: 1)], weights: [0.3, 1, 1]),
            column([.photo(index: 2), .photo(index: 3), .spacer], weights: [1, 1, 0.3])
        ]))
    ]

    private static let fivePhotoTemplates: [MemoryAlbumSectionLayoutTemplate] = [
        .init(layoutCount: 5, variant: 0, title: "Feature Left", subtitle: "Big left + 2x2 right", selectionHeight: 280, albumHeight: 320, contentInset: 0, node: row([.photo(index: 0), column([row([.photo(index: 1), .photo(index: 2)]), row([.photo(index: 3), .photo(index: 4)])])], weights: [1.3, 1])),
        .init(layoutCount: 5, variant: 1, title: "Feature Right", subtitle: "2x2 left + big right", selectionHeight: 280, albumHeight: 320, contentInset: 0, node: row([column([row([.photo(index: 0), .photo(index: 1)]), row([.photo(index: 2), .photo(index: 3)])]), .photo(index: 4)], weights: [1, 1.3])),
        .init(layoutCount: 5, variant: 2, title: "Top Hero", subtitle: "Big top + two rows below", selectionHeight: 300, albumHeight: 340, contentInset: 0, node: column([.photo(index: 0), row([.photo(index: 1), .photo(index: 2)]), row([.photo(index: 3), .photo(index: 4)])], weights: [1.2, 1, 1])),
        .init(layoutCount: 5, variant: 3, title: "Bottom Hero", subtitle: "Two rows top + big bottom", selectionHeight: 300, albumHeight: 340, contentInset: 0, node: column([row([.photo(index: 0), .photo(index: 1)]), row([.photo(index: 2), .photo(index: 3)]), .photo(index: 4)], weights: [1, 1, 1.2])),
        .init(layoutCount: 5, variant: 4, title: "Five Columns", subtitle: "Horizontal sequence", selectionHeight: 165, albumHeight: 205, contentInset: 0, node: row([.photo(index: 0), .photo(index: 1), .photo(index: 2), .photo(index: 3), .photo(index: 4)])),
        .init(layoutCount: 5, variant: 5, title: "Five Rows", subtitle: "Vertical sequence", selectionHeight: 360, albumHeight: 400, contentInset: 0, node: column([.photo(index: 0), .photo(index: 1), .photo(index: 2), .photo(index: 3), .photo(index: 4)])),
        .init(layoutCount: 5, variant: 6, title: "Two Over Three", subtitle: "2 photos above 3", selectionHeight: 270, albumHeight: 310, contentInset: 0, node: column([row([.photo(index: 0), .photo(index: 1)]), row([.photo(index: 2), .photo(index: 3), .photo(index: 4)])])),
        .init(layoutCount: 5, variant: 7, title: "Three Over Two", subtitle: "3 photos above 2", selectionHeight: 270, albumHeight: 310, contentInset: 0, node: column([row([.photo(index: 0), .photo(index: 1), .photo(index: 2)]), row([.photo(index: 3), .photo(index: 4)])])),
        .init(layoutCount: 5, variant: 8, title: "Dual Story", subtitle: "Two left rows + three right rows", selectionHeight: 285, albumHeight: 325, contentInset: 0, node: row([column([.photo(index: 0), .photo(index: 1)]), column([.photo(index: 2), .photo(index: 3), .photo(index: 4)])], weights: [1, 1.05])),
        .init(layoutCount: 5, variant: 9, title: "Dual Story Mirror", subtitle: "Three left rows + two right rows", selectionHeight: 285, albumHeight: 325, contentInset: 0, node: row([column([.photo(index: 0), .photo(index: 1), .photo(index: 2)]), column([.photo(index: 3), .photo(index: 4)])], weights: [1.05, 1])),
        .init(layoutCount: 5, variant: 10, title: "Center Hero", subtitle: "Rows around a big center", selectionHeight: 300, albumHeight: 340, contentInset: 0, node: column([row([.photo(index: 0), .photo(index: 1)]), .photo(index: 2), row([.photo(index: 3), .photo(index: 4)])], weights: [1, 1.25, 1])),
        .init(layoutCount: 5, variant: 11, title: "Inset Mosaic", subtitle: "Soft padded 2x3 blend", selectionHeight: 295, albumHeight: 335, contentInset: MindMorySpacing.sm, node: column([row([.photo(index: 0), .photo(index: 1)]), row([.photo(index: 2), .photo(index: 3), .photo(index: 4)])], spacing: MindMorySpacing.xs))
    ]

    private static func row(
        _ children: [MemoryAlbumSectionLayoutNode],
        weights: [CGFloat] = [],
        spacing: CGFloat = MindMorySpacing.sm
    ) -> MemoryAlbumSectionLayoutNode {
        .split(axis: .horizontal, children: children, weights: weights, spacing: spacing)
    }

    private static func column(
        _ children: [MemoryAlbumSectionLayoutNode],
        weights: [CGFloat] = [],
        spacing: CGFloat = MindMorySpacing.sm
    ) -> MemoryAlbumSectionLayoutNode {
        .split(axis: .vertical, children: children, weights: weights, spacing: spacing)
    }
}

struct MemoryAlbumSectionLayoutRenderer<CellContent: View>: View {
    let template: MemoryAlbumSectionLayoutTemplate
    let cellContent: (Int) -> CellContent

    var body: some View {
        GeometryReader { geometry in
            let inset = template.contentInset
            let innerSize = CGSize(
                width: Swift.max(geometry.size.width - (inset * 2), 0),
                height: Swift.max(geometry.size.height - (inset * 2), 0)
            )

            layoutNodeView(template.node, in: innerSize)
                .frame(width: innerSize.width, height: innerSize.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .clipped()
    }

    private func layoutNodeView(_ node: MemoryAlbumSectionLayoutNode, in size: CGSize) -> AnyView {
        switch node {
        case .photo(let index):
            return AnyView(
                cellContent(index)
                    .frame(width: size.width, height: size.height)
                    .clipped()
            )
        case .spacer:
            return AnyView(
                Color.clear
                    .frame(width: size.width, height: size.height)
            )
        case .split(let axis, let children, let weights, let spacing):
            let ratios = normalizedWeights(weights, count: children.count)

            switch axis {
            case .horizontal:
                let widths = measuredLengths(total: size.width, spacing: spacing, ratios: ratios)
                return AnyView(
                    HStack(spacing: spacing) {
                        ForEach(children.indices, id: \.self) { childIndex in
                            layoutNodeView(children[childIndex], in: CGSize(width: widths[childIndex], height: size.height))
                        }
                    }
                    .frame(width: size.width, height: size.height, alignment: .topLeading)
                    .clipped()
                )
            case .vertical:
                let heights = measuredLengths(total: size.height, spacing: spacing, ratios: ratios)
                return AnyView(
                    VStack(spacing: spacing) {
                        ForEach(children.indices, id: \.self) { childIndex in
                            layoutNodeView(children[childIndex], in: CGSize(width: size.width, height: heights[childIndex]))
                        }
                    }
                    .frame(width: size.width, height: size.height, alignment: .topLeading)
                    .clipped()
                )
            }
        }
    }

    private func normalizedWeights(_ weights: [CGFloat], count: Int) -> [CGFloat] {
        guard count > 0 else { return [] }

        let safeWeights: [CGFloat]
        if weights.count == count {
            safeWeights = weights.map { Swift.max($0, 0.001) }
        } else {
            safeWeights = Array(repeating: 1, count: count)
        }

        let total = safeWeights.reduce(0, +)
        guard total > 0 else {
            return Array(repeating: 1 / CGFloat(count), count: count)
        }

        return safeWeights.map { $0 / total }
    }

    private func measuredLengths(total: CGFloat, spacing: CGFloat, ratios: [CGFloat]) -> [CGFloat] {
        guard !ratios.isEmpty else { return [] }

        let totalSpacing = spacing * CGFloat(Swift.max(ratios.count - 1, 0))
        let available = Swift.max(total - totalSpacing, 0)
        var lengths = Array(repeating: CGFloat.zero, count: ratios.count)
        var consumed: CGFloat = 0

        for index in ratios.indices {
            if index == ratios.count - 1 {
                lengths[index] = Swift.max(available - consumed, 0)
            } else {
                let length = floor((available * ratios[index]) * 1000) / 1000
                lengths[index] = Swift.max(length, 0)
                consumed += lengths[index]
            }
        }

        return lengths
    }
}

struct MemoryAlbumSectionTemplateCard: View {
    let template: MemoryAlbumSectionLayoutTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            HStack(spacing: MindMorySpacing.xs) {
                Text(template.title)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.textPrimary)

                Spacer(minLength: MindMorySpacing.sm)

                Text("Layout \(template.variant + 1)")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }

            Text(template.subtitle)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)

            MemoryAlbumSectionLayoutRenderer(template: template) { _ in
                placeholderCell
            }
            .frame(height: template.selectionHeight)
        }
        .padding(MindMorySpacing.md)
        .background(MindMoryColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                .stroke(MindMoryColors.border)
        )
    }

    private var placeholderCell: some View {
        Color(MindMoryColors.background)
            .overlay(
                Image(systemName: "photo")
                    .font(.title3)
                    .foregroundStyle(MindMoryColors.textSecondary)
            )
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                    .stroke(MindMoryColors.border)
            )
    }
}