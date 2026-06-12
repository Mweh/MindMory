import SwiftUI
import UIKit

enum MemoryAlbumFrameShape: String, CaseIterable, Codable, Equatable {
    case portrait
    case landscape
    case square
    case flexible

    var iconName: String {
        switch self {
        case .portrait: return "rectangle.portrait"
        case .landscape: return "rectangle"
        case .square: return "square"
        case .flexible: return "aspectratio"
        }
    }

    var label: String { rawValue.capitalized }

    var heightMultiplier: CGFloat {
        switch self {
        case .portrait: return 4.0 / 3.0
        case .landscape: return 3.0 / 4.0
        case .square: return 1.0
        case .flexible: return 1.0
        }
    }
}

enum MirrorType: Equatable {
    case none
    case vertical  // left-right mirror (column flip)
    case horizontal  // top-bottom mirror (row flip)
}

struct MirrorGroup: Equatable {
    let primaryVariant: Int
    let mirrorVariant: Int
    let mirrorType: MirrorType  // indicates if it's left-right or top-bottom
}

struct MemoryAlbumSectionLayoutTemplate: Identifiable, Equatable {
    let id: String
    let layoutCount: Int
    let variant: Int
    let title: String
    let albumHeight: CGFloat
    let gridColumns: [GridItem]
    let frameShapes: [MemoryAlbumFrameShape]
    let mirrorGroup: MirrorGroup?

    init(layoutCount: Int, variant: Int, title: String, albumHeight: CGFloat, gridColumns: [GridItem], frameShapes: [MemoryAlbumFrameShape]? = nil, mirrorGroup: MirrorGroup? = nil) {
        self.id = "album-layout-\(layoutCount)-\(variant)"
        self.layoutCount = layoutCount
        self.variant = variant
        self.title = title
        self.albumHeight = albumHeight
        self.gridColumns = gridColumns
        if let shapes = frameShapes, shapes.count == layoutCount {
            self.frameShapes = shapes
        } else {
            self.frameShapes = Array(repeating: .square, count: layoutCount)
        }
        self.mirrorGroup = mirrorGroup
    }

    static func == (lhs: MemoryAlbumSectionLayoutTemplate, rhs: MemoryAlbumSectionLayoutTemplate) -> Bool {
        lhs.id == rhs.id
            && lhs.layoutCount == rhs.layoutCount
            && lhs.variant == rhs.variant
            && lhs.title == rhs.title
            && lhs.albumHeight == rhs.albumHeight
            && lhs.frameShapes == rhs.frameShapes
            && lhs.mirrorGroup == rhs.mirrorGroup
    }

    func estimatedHeight(forWidth width: CGFloat, spacing: CGFloat = MindMorySpacing.sm) -> CGFloat {
        func shape(at index: Int) -> MemoryAlbumFrameShape {
            guard frameShapes.indices.contains(index) else { return .square }
            return frameShapes[index]
        }

        func rowHeight(forIndices indices: [Int], columns: Int, availableWidth: CGFloat) -> CGFloat {
            guard !indices.isEmpty else { return 0 }
            let totalSpacing = CGFloat(max(0, columns - 1)) * spacing
            let cellWidth = (availableWidth - totalSpacing) / CGFloat(columns)
            var maxHeight: CGFloat = 0
            for idx in indices {
                let mult = shape(at: idx).heightMultiplier
                maxHeight = max(maxHeight, cellWidth * mult)
            }
            return maxHeight
        }

        switch layoutCount {
        case 1:
            let mult = shape(at: 0).heightMultiplier
            return width * mult

        case 2:
            switch variant {
            case 1: // stacked vertical
                let h0 = width * shape(at: 0).heightMultiplier
                let h1 = width * shape(at: 1).heightMultiplier
                return h0 + spacing + h1

            case 2: // focus split (left larger)
                let leftWidth = width * 0.66 - spacing * 0.33
                let rightWidth = width - leftWidth - spacing
                let hLeft = leftWidth * shape(at: 0).heightMultiplier
                let hRight = rightWidth * shape(at: 1).heightMultiplier
                return max(hLeft, hRight)

            case 3: // reverse focus (right larger)
                let rightWidth = width * 0.66 - spacing * 0.33
                let leftWidth = width - rightWidth - spacing
                let hLeft = leftWidth * shape(at: 0).heightMultiplier
                let hRight = rightWidth * shape(at: 1).heightMultiplier
                return max(hLeft, hRight)

            default: // side-by-side
                return rowHeight(forIndices: [0, 1], columns: 2, availableWidth: width)
            }

        case 3:
            switch variant {
            case 1: // large left + stacked
                let leftMults: [CGFloat] = [shape(at: 0).heightMultiplier, shape(at: 1).heightMultiplier]
                let rightMults: [CGFloat] = [shape(at: 2).heightMultiplier]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                return sizes.height

            case 2: // top row + wide bottom
                let top = rowHeight(forIndices: [0, 1], columns: 2, availableWidth: width)
                let bottom = width * shape(at: 2).heightMultiplier
                return top + spacing + bottom

            case 3: // large top + split bottom
                let top = width * shape(at: 0).heightMultiplier
                let bottom = rowHeight(forIndices: [1, 2], columns: 2, availableWidth: width)
                return top + spacing + bottom

            default: // three across
                return rowHeight(forIndices: [0, 1, 2], columns: 3, availableWidth: width)
            }

        case 4:
            switch variant {
            case 1: // tall left + stack
                let leftMults: [CGFloat] = [shape(at: 0).heightMultiplier]
                let rightMults: [CGFloat] = [shape(at: 1).heightMultiplier, shape(at: 2).heightMultiplier, shape(at: 3).heightMultiplier]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                return sizes.height

            case 2: // mixed split (2x2)
                let rowH = rowHeight(forIndices: [0, 1], columns: 2, availableWidth: width)
                let rowH2 = rowHeight(forIndices: [2, 3], columns: 2, availableWidth: width)
                return rowH + spacing + rowH2

            case 3: // full-width top
                let top = width * shape(at: 0).heightMultiplier
                let bottom = rowHeight(forIndices: [1, 2, 3], columns: 3, availableWidth: width)
                return top + spacing + bottom

            default: // squared grid 2x2
                let rowH = rowHeight(forIndices: [0, 1], columns: 2, availableWidth: width)
                let rowH2 = rowHeight(forIndices: [2, 3], columns: 2, availableWidth: width)
                return rowH + spacing + rowH2
            }

        case 5:
            switch variant {
            case 1: // three top + two bottom
                let top = rowHeight(forIndices: [0, 1, 2], columns: 3, availableWidth: width)
                let bottom = rowHeight(forIndices: [3, 4], columns: 2, availableWidth: width)
                return top + spacing + bottom

            case 2: // two left + three right (column focus)
                let leftMults: [CGFloat] = [shape(at: 0).heightMultiplier, shape(at: 1).heightMultiplier]
                let rightMults: [CGFloat] = [shape(at: 2).heightMultiplier, shape(at: 3).heightMultiplier, shape(at: 4).heightMultiplier]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                return sizes.height

            case 3: // single left + 2x2 right grid
                let leftWidth = width * 0.33 - spacing * 0.33
                let leftHeight = leftWidth * shape(at: 0).heightMultiplier
                let rightWidth = width - leftWidth - spacing
                let rightTop = rowHeight(forIndices: [1, 2], columns: 2, availableWidth: rightWidth)
                let rightBottom = rowHeight(forIndices: [3, 4], columns: 2, availableWidth: rightWidth)
                let rightTotal = rightTop + spacing + rightBottom
                return max(leftHeight, rightTotal)

            case 4: // 2 top + 3 bottom
                let top = rowHeight(forIndices: [0, 1], columns: 2, availableWidth: width)
                let bottom = rowHeight(forIndices: [2, 3, 4], columns: 3, availableWidth: width)
                return top + spacing + bottom

            default: // default column split (2 + 3)
                let leftMults: [CGFloat] = [shape(at: 0).heightMultiplier, shape(at: 1).heightMultiplier]
                let rightMults: [CGFloat] = [shape(at: 2).heightMultiplier, shape(at: 3).heightMultiplier, shape(at: 4).heightMultiplier]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                return sizes.height
            }

        default:
            // fallback: estimate as grid
            let cols = min(layoutCount, 3)
            let rows = Int(ceil(Double(layoutCount) / Double(cols)))
            let rowH = rowHeight(forIndices: Array(0..<min(layoutCount, cols)), columns: cols, availableWidth: width)
            return CGFloat(rows) * rowH + CGFloat(max(0, rows - 1)) * spacing
        }
    }
}

enum MemoryAlbumSectionLayoutCatalog {
    static func template(layoutCount: Int, variant: Int) -> MemoryAlbumSectionLayoutTemplate {
        let items = templates(for: layoutCount)
        if let match = items.first(where: { $0.variant == variant }) { return match }
        guard !items.isEmpty else { fatalError("No templates available for layoutCount \(layoutCount)") }
        let fallbackIndex = abs(variant) % items.count
        return items[fallbackIndex]
    }

    static func templates(for layoutCount: Int) -> [MemoryAlbumSectionLayoutTemplate] {
        let height = defaultAlbumHeight(for: layoutCount)

        var base: [MemoryAlbumSectionLayoutTemplate]

        switch layoutCount {
        case 1:
            base = [
                MemoryAlbumSectionLayoutTemplate(layoutCount: 1, variant: 0, title: "Single (portrait)", albumHeight: height, gridColumns: [.init(.flexible())], frameShapes: [.portrait]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 1, variant: 1, title: "Single (landscape)", albumHeight: height, gridColumns: [.init(.flexible())], frameShapes: [.landscape]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 1, variant: 2, title: "Single (square)", albumHeight: height, gridColumns: [.init(.flexible())], frameShapes: [.square])
            ]

        case 2:
            base = [
                MemoryAlbumSectionLayoutTemplate(layoutCount: 2, variant: 0, title: "Side-by-side (equal)", albumHeight: height, gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 2), frameShapes: [.square, .square]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 2, variant: 1, title: "Stacked (vertical)", albumHeight: height, gridColumns: [.init(.flexible())], frameShapes: [.portrait, .portrait]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 2, variant: 2, title: "Split layout", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.landscape, .portrait], mirrorGroup: MirrorGroup(primaryVariant: 2, mirrorVariant: 3, mirrorType: .vertical)),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 2, variant: 3, title: "Split layout (mirrored)", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.portrait, .landscape], mirrorGroup: MirrorGroup(primaryVariant: 2, mirrorVariant: 3, mirrorType: .vertical))
            ]

        case 3:
            base = [
                MemoryAlbumSectionLayoutTemplate(layoutCount: 3, variant: 0, title: "Three across", albumHeight: height, gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3), frameShapes: [.square, .square, .square]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 3, variant: 1, title: "Large left + stacked", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.landscape, .portrait, .portrait]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 3, variant: 2, title: "Split stacked layout", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.square, .square, .landscape], mirrorGroup: MirrorGroup(primaryVariant: 2, mirrorVariant: 3, mirrorType: .horizontal)),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 3, variant: 3, title: "Split stacked layout (mirrored)", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.portrait, .square, .square], mirrorGroup: MirrorGroup(primaryVariant: 2, mirrorVariant: 3, mirrorType: .horizontal))
            ]

        case 4:
            base = [
                MemoryAlbumSectionLayoutTemplate(layoutCount: 4, variant: 0, title: "Squared grid (2x2)", albumHeight: height, gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 2), frameShapes: [.square, .square, .square, .square]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 4, variant: 1, title: "Tall left + stacked", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.portrait, .portrait, .portrait, .portrait]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 4, variant: 2, title: "Two columns (2+2)", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.landscape, .landscape, .landscape, .landscape]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 4, variant: 3, title: "Full-width top + three bottom", albumHeight: height, gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3), frameShapes: [.landscape, .square, .square, .square]),
                // new: staggered two-column variant where the right column is visually offset
                MemoryAlbumSectionLayoutTemplate(layoutCount: 4, variant: 4, title: "Staggered columns", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.portrait, .portrait, .portrait, .portrait])
            ]

        case 5:
            base = [
                MemoryAlbumSectionLayoutTemplate(layoutCount: 5, variant: 0, title: "Split stacked layout", albumHeight: height, gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3), frameShapes: [.square, .square, .square, .square, .square], mirrorGroup: MirrorGroup(primaryVariant: 0, mirrorVariant: 3, mirrorType: .horizontal)),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 5, variant: 1, title: "Two left + three right", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.portrait, .portrait, .landscape, .landscape, .landscape]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 5, variant: 2, title: "Single left + 2x2 right", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.portrait, .square, .square, .square, .square]),
                MemoryAlbumSectionLayoutTemplate(layoutCount: 5, variant: 3, title: "Split stacked layout (mirrored)", albumHeight: height, gridColumns: [.init(.flexible()), .init(.flexible())], frameShapes: [.square, .square, .square, .square, .square], mirrorGroup: MirrorGroup(primaryVariant: 0, mirrorVariant: 3, mirrorType: .horizontal))
            ]

        default:
            base = [
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: layoutCount,
                    variant: 0,
                    title: "Grid",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: min(layoutCount, 3)),
                    frameShapes: Array(repeating: .square, count: layoutCount)
                )
            ]
        }

        // Return the curated base templates only — avoid generating permutation combinations
        return base
    }

    private static func defaultAlbumHeight(for layoutCount: Int) -> CGFloat {
        switch layoutCount {
        case 1: return 260
        case 2: return 220
        case 3: return 240
        case 4: return 260
        case 5: return 280
        default: return 240
        }
    }
}

// Helper: compute column widths so vertically stacked groups align height-wise when possible.
private func computeBalancedColumnWidths(totalWidth: CGFloat, spacingBetweenColumns: CGFloat, leftMultipliers: [CGFloat], rightMultipliers: [CGFloat], minColumnWidth: CGFloat = 44) -> (left: CGFloat, right: CGFloat, height: CGFloat) {
    let leftSum = leftMultipliers.reduce(0, +)
    let rightSum = rightMultipliers.reduce(0, +)
    let leftSpacingTotal = CGFloat(max(0, leftMultipliers.count - 1)) * spacingBetweenColumns
    let rightSpacingTotal = CGFloat(max(0, rightMultipliers.count - 1)) * spacingBetweenColumns

    var leftWidth: CGFloat = (totalWidth - spacingBetweenColumns) / 2
    var rightWidth: CGFloat = (totalWidth - spacingBetweenColumns) / 2

    let denom = leftSum + rightSum
    if denom > 0 {
        // solve for widths so: leftWidth * leftSum + leftSpacingTotal == rightWidth * rightSum + rightSpacingTotal
        // with leftWidth + spacingBetweenColumns + rightWidth == totalWidth
        let computedRight = (leftSum * (totalWidth - spacingBetweenColumns) + leftSpacingTotal - rightSpacingTotal) / denom
        rightWidth = computedRight
        leftWidth = totalWidth - spacingBetweenColumns - rightWidth
    }

    // clamp to sensible minimums
    if rightWidth < minColumnWidth {
        rightWidth = minColumnWidth
        leftWidth = totalWidth - spacingBetweenColumns - rightWidth
    }
    if leftWidth < minColumnWidth {
        leftWidth = minColumnWidth
        rightWidth = totalWidth - spacingBetweenColumns - leftWidth
    }

    if leftWidth.isNaN || rightWidth.isNaN || leftWidth <= 0 || rightWidth <= 0 {
        leftWidth = max(minColumnWidth, (totalWidth - spacingBetweenColumns) / 2)
        rightWidth = totalWidth - spacingBetweenColumns - leftWidth
    }

    let leftHeight = leftWidth * leftSum + leftSpacingTotal
    let rightHeight = rightWidth * rightSum + rightSpacingTotal
    let height = max(leftHeight, rightHeight)

    return (leftWidth, rightWidth, height)
}

struct MemoryAlbumSectionLayoutRenderer<Content: View>: View {
    let template: MemoryAlbumSectionLayoutTemplate
    let content: (Int) -> Content
    // Optional externally provided width; when nil we'll fall back to a sensible screen-safe width
    var availableWidth: CGFloat? = nil

    var body: some View {
        let screenWidth: CGFloat = {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                return scene.screen.bounds.width
            }
            return UIScreen.main.bounds.width
        }()

        let width = availableWidth ?? (screenWidth - (MindMorySpacing.xl * 2))
        let spacing = MindMorySpacing.sm

        switch template.layoutCount {
        case 1:
            let mult = template.frameShapes.safe(0)?.heightMultiplier ?? MemoryAlbumFrameShape.square.heightMultiplier
            imageCell(0)
                .frame(width: width, height: width * mult)

        case 2:
            switch template.variant {
            case 1: // stacked vertical
                let h0 = width * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let h1 = width * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                VStack(spacing: spacing) {
                    imageCell(0).frame(width: width, height: h0)
                    imageCell(1).frame(width: width, height: h1)
                }
                .frame(width: width, height: h0 + spacing + h1)

            case 2: // focus split (left larger)
                let leftWidth = width * 0.66 - spacing * 0.33
                let rightWidth = width - leftWidth - spacing
                let hLeft = leftWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let hRight = rightWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                HStack(spacing: spacing) {
                    imageCell(0).frame(width: leftWidth, height: hLeft)
                    imageCell(1).frame(width: rightWidth, height: hRight)
                }
                .frame(width: width, height: max(hLeft, hRight))

            case 3: // reverse focus (right larger)
                let rightWidth = width * 0.66 - spacing * 0.33
                let leftWidth = width - rightWidth - spacing
                let hLeft = leftWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let hRight = rightWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                HStack(spacing: spacing) {
                    imageCell(0).frame(width: leftWidth, height: hLeft)
                    imageCell(1).frame(width: rightWidth, height: hRight)
                }
                .frame(width: width, height: max(hLeft, hRight))

            default: // side-by-side
                let cols = 2
                let totalSpacing = CGFloat(max(0, cols - 1)) * spacing
                let cellWidth = (width - totalSpacing) / CGFloat(cols)
                let h0 = cellWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let h1 = cellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                let rowH = max(h0, h1)
                HStack(spacing: spacing) {
                    imageCell(0).frame(width: cellWidth, height: h0)
                    imageCell(1).frame(width: cellWidth, height: h1)
                }
                .frame(width: width, height: rowH)
            }

        case 3:
            switch template.variant {
            case 1: // large left + stacked
                let leftMults: [CGFloat] = [template.frameShapes.safe(0)?.heightMultiplier ?? 1, template.frameShapes.safe(1)?.heightMultiplier ?? 1]
                let rightMults: [CGFloat] = [template.frameShapes.safe(2)?.heightMultiplier ?? 1]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                let leftWidth = sizes.left
                let rightWidth = sizes.right
                let leftTop = leftWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let leftBottom = leftWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                let rightHeight = rightWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1)
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        imageCell(0).frame(width: leftWidth, height: leftTop)
                        imageCell(1).frame(width: leftWidth, height: leftBottom)
                    }
                    imageCell(2).frame(width: rightWidth, height: rightHeight)
                }
                .frame(width: width, height: sizes.height)

            case 2: // top row + wide bottom
                let cols = 2
                let totalSpacing = CGFloat(max(0, cols - 1)) * spacing
                let topCellWidth = (width - totalSpacing) / CGFloat(cols)
                let topHeight = max(topCellWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1), topCellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1))
                let bottomHeight = width * (template.frameShapes.safe(2)?.heightMultiplier ?? 1)
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        imageCell(0).frame(width: topCellWidth, height: topHeight)
                        imageCell(1).frame(width: topCellWidth, height: topHeight)
                    }
                    imageCell(2).frame(width: width, height: bottomHeight)
                }
                .frame(width: width, height: topHeight + spacing + bottomHeight)

            case 3: // large top + split bottom
                let topHeight = width * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let cols = 2
                let totalSpacing = CGFloat(max(0, cols - 1)) * spacing
                let bottomCellWidth = (width - totalSpacing) / CGFloat(cols)
                let bottomHeight = max(bottomCellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1), bottomCellWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1))
                VStack(spacing: spacing) {
                    imageCell(0).frame(width: width, height: topHeight)
                    HStack(spacing: spacing) {
                        imageCell(1).frame(width: bottomCellWidth, height: bottomHeight)
                        imageCell(2).frame(width: bottomCellWidth, height: bottomHeight)
                    }
                }
                .frame(width: width, height: topHeight + spacing + bottomHeight)

                default: // three across
                let cols = 3
                let totalSpacing = CGFloat(max(0, cols - 1)) * spacing
                let cellWidth = (width - totalSpacing) / CGFloat(cols)
                let h0 = cellWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let h1 = cellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                let h2 = cellWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1)
                let rowH = max(h0, h1, h2)
                HStack(spacing: spacing) {
                    imageCell(0).frame(width: cellWidth, height: h0)
                    imageCell(1).frame(width: cellWidth, height: h1)
                    imageCell(2).frame(width: cellWidth, height: h2)
                }
                .frame(width: width, height: rowH)
            }

        case 4:
            switch template.variant {
            case 1: // tall left + stack
                let leftMults: [CGFloat] = [template.frameShapes.safe(0)?.heightMultiplier ?? 1]
                let rightMults: [CGFloat] = [template.frameShapes.safe(1)?.heightMultiplier ?? 1, template.frameShapes.safe(2)?.heightMultiplier ?? 1, template.frameShapes.safe(3)?.heightMultiplier ?? 1]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                let leftWidth = sizes.left
                let rightWidth = sizes.right
                let leftHeight = leftWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let rightTop = rightWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                let rightMid = rightWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1)
                let rightBot = rightWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1)
                HStack(spacing: spacing) {
                    imageCell(0).frame(width: leftWidth, height: leftHeight)
                    VStack(spacing: spacing) {
                        imageCell(1).frame(width: rightWidth, height: rightTop)
                        imageCell(2).frame(width: rightWidth, height: rightMid)
                        imageCell(3).frame(width: rightWidth, height: rightBot)
                    }
                }
                .frame(width: width, height: sizes.height)

            case 2: // mixed split (2x2)
                let cols = 2
                let totalSpacing = CGFloat(max(0, cols - 1)) * spacing
                let cellWidth = (width - totalSpacing) / CGFloat(cols)
                let rowH = max(cellWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1), cellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1))
                let rowH2 = max(cellWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1), cellWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1))
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        imageCell(0).frame(width: cellWidth, height: rowH)
                        imageCell(1).frame(width: cellWidth, height: rowH)
                    }
                    HStack(spacing: spacing) {
                        imageCell(2).frame(width: cellWidth, height: rowH2)
                        imageCell(3).frame(width: cellWidth, height: rowH2)
                    }
                }
                .frame(width: width, height: rowH + spacing + rowH2)

            case 3: // full-width top
                let top = width * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let cols = 3
                let totalSpacing = CGFloat(max(0, cols - 1)) * spacing
                let bottomCellWidth = (width - totalSpacing) / CGFloat(cols)
                let bottom = max(bottomCellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1), bottomCellWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1), bottomCellWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1))
                VStack(spacing: spacing) {
                    imageCell(0).frame(width: width, height: top)
                    HStack(spacing: spacing) {
                        imageCell(1).frame(width: bottomCellWidth, height: bottom)
                        imageCell(2).frame(width: bottomCellWidth, height: bottom)
                        imageCell(3).frame(width: bottomCellWidth, height: bottom)
                    }
                }
                .frame(width: width, height: top + spacing + bottom)

            case 4: // staggered columns (offset right column)
                let leftMults: [CGFloat] = [template.frameShapes.safe(0)?.heightMultiplier ?? 1, template.frameShapes.safe(1)?.heightMultiplier ?? 1]
                let rightMults: [CGFloat] = [template.frameShapes.safe(2)?.heightMultiplier ?? 1, template.frameShapes.safe(3)?.heightMultiplier ?? 1]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                let leftWidth = sizes.left
                let rightWidth = sizes.right
                let leftTop = leftWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let leftBottom = leftWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                let leftTotal = leftTop + spacing + leftBottom
                let rightTop = rightWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1)
                let rightBottom = rightWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1)
                let rightTotal = rightTop + spacing + rightBottom
                // visual offset applied to right column; include offset in computed height so layout doesn't clip
                let rightOffset = spacing * 1.5
                let containerHeight = max(leftTotal, rightTotal + rightOffset)
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        imageCell(0).frame(width: leftWidth, height: leftTop)
                        imageCell(1).frame(width: leftWidth, height: leftBottom)
                    }
                    VStack(spacing: spacing) {
                        imageCell(2).frame(width: rightWidth, height: rightTop)
                        imageCell(3).frame(width: rightWidth, height: rightBottom)
                    }
                    .padding(.top, rightOffset)
                }
                .frame(width: width, height: containerHeight)

                default: // squared grid 2x2
                let cols = 2
                let totalSpacing = CGFloat(max(0, cols - 1)) * spacing
                let cellWidth = (width - totalSpacing) / CGFloat(cols)
                let h0 = cellWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let h1 = cellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1)
                let h2 = cellWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1)
                let h3 = cellWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1)
                let rowH1 = max(h0, h1)
                let rowH2 = max(h2, h3)
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        imageCell(0).frame(width: cellWidth, height: h0)
                        imageCell(1).frame(width: cellWidth, height: h1)
                    }
                    HStack(spacing: spacing) {
                        imageCell(2).frame(width: cellWidth, height: h2)
                        imageCell(3).frame(width: cellWidth, height: h3)
                    }
                }
                .frame(width: width, height: rowH1 + spacing + rowH2)
            }

        case 5:
            switch template.variant {
            case 1: // three top + two bottom
                let topCols = 3
                let totalSpacingTop = CGFloat(max(0, topCols - 1)) * spacing
                let topCellWidth = (width - totalSpacingTop) / CGFloat(topCols)
                let top = max(topCellWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1), topCellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1), topCellWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1))
                let bottomCols = 2
                let totalSpacingBottom = CGFloat(max(0, bottomCols - 1)) * spacing
                let bottomCellWidth = (width - totalSpacingBottom) / CGFloat(bottomCols)
                let bottom = max(bottomCellWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1), bottomCellWidth * (template.frameShapes.safe(4)?.heightMultiplier ?? 1))
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        imageCell(0).frame(width: topCellWidth, height: top)
                        imageCell(1).frame(width: topCellWidth, height: top)
                        imageCell(2).frame(width: topCellWidth, height: top)
                    }
                    HStack(spacing: spacing) {
                        imageCell(3).frame(width: bottomCellWidth, height: bottom)
                        imageCell(4).frame(width: bottomCellWidth, height: bottom)
                    }
                }
                .frame(width: width, height: top + spacing + bottom)

            case 2: // two left + three right (column focus)
                let leftMults: [CGFloat] = [template.frameShapes.safe(0)?.heightMultiplier ?? 1, template.frameShapes.safe(1)?.heightMultiplier ?? 1]
                let rightMults: [CGFloat] = [template.frameShapes.safe(2)?.heightMultiplier ?? 1, template.frameShapes.safe(3)?.heightMultiplier ?? 1, template.frameShapes.safe(4)?.heightMultiplier ?? 1]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                let leftWidth = sizes.left
                let rightWidth = sizes.right
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        imageCell(0).frame(width: leftWidth, height: leftWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1))
                        imageCell(1).frame(width: leftWidth, height: leftWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1))
                    }
                    VStack(spacing: spacing) {
                        imageCell(2).frame(width: rightWidth, height: rightWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1))
                        imageCell(3).frame(width: rightWidth, height: rightWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1))
                        imageCell(4).frame(width: rightWidth, height: rightWidth * (template.frameShapes.safe(4)?.heightMultiplier ?? 1))
                    }
                }
                .frame(width: width, height: sizes.height)

            case 3: // single left + 2x2 right
                let leftWidth = width * 0.33 - spacing * 0.33
                let leftHeight = leftWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1)
                let rightWidth = width - leftWidth - spacing
                let rightTop = max((rightWidth - spacing)/2 * (template.frameShapes.safe(1)?.heightMultiplier ?? 1), (rightWidth - spacing)/2 * (template.frameShapes.safe(2)?.heightMultiplier ?? 1))
                let rightBottom = max((rightWidth - spacing)/2 * (template.frameShapes.safe(3)?.heightMultiplier ?? 1), (rightWidth - spacing)/2 * (template.frameShapes.safe(4)?.heightMultiplier ?? 1))
                let rightTotal = rightTop + spacing + rightBottom
                HStack(spacing: spacing) {
                    imageCell(0).frame(width: leftWidth, height: leftHeight)
                    VStack(spacing: spacing) {
                        HStack(spacing: spacing) {
                            imageCell(1).frame(width: (rightWidth - spacing)/2, height: rightTop)
                            imageCell(2).frame(width: (rightWidth - spacing)/2, height: rightTop)
                        }
                        HStack(spacing: spacing) {
                            imageCell(3).frame(width: (rightWidth - spacing)/2, height: rightBottom)
                            imageCell(4).frame(width: (rightWidth - spacing)/2, height: rightBottom)
                        }
                    }
                }
                .frame(width: width, height: max(leftHeight, rightTotal))

            case 4: // 2 top + 3 bottom
                let topCols = 2
                let totalTopSpacing = CGFloat(max(0, topCols - 1)) * spacing
                let topCellWidth = (width - totalTopSpacing) / CGFloat(topCols)
                let top = max(topCellWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1), topCellWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1))
                let bottomCols = 3
                let totalBottomSpacing = CGFloat(max(0, bottomCols - 1)) * spacing
                let bottomCellWidth = (width - totalBottomSpacing) / CGFloat(bottomCols)
                let bottom = max(bottomCellWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1), bottomCellWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1), bottomCellWidth * (template.frameShapes.safe(4)?.heightMultiplier ?? 1))
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        imageCell(0).frame(width: topCellWidth, height: top)
                        imageCell(1).frame(width: topCellWidth, height: top)
                    }
                    HStack(spacing: spacing) {
                        imageCell(2).frame(width: bottomCellWidth, height: bottom)
                        imageCell(3).frame(width: bottomCellWidth, height: bottom)
                        imageCell(4).frame(width: bottomCellWidth, height: bottom)
                    }
                }
                .frame(width: width, height: top + spacing + bottom)

            default: // default column split (2 + 3)
                let leftMults: [CGFloat] = [template.frameShapes.safe(0)?.heightMultiplier ?? 1, template.frameShapes.safe(1)?.heightMultiplier ?? 1]
                let rightMults: [CGFloat] = [template.frameShapes.safe(2)?.heightMultiplier ?? 1, template.frameShapes.safe(3)?.heightMultiplier ?? 1, template.frameShapes.safe(4)?.heightMultiplier ?? 1]
                let sizes = computeBalancedColumnWidths(totalWidth: width, spacingBetweenColumns: spacing, leftMultipliers: leftMults, rightMultipliers: rightMults)
                let leftWidth = sizes.left
                let rightWidth = sizes.right
                HStack(spacing: spacing) {
                    VStack(spacing: spacing) {
                        imageCell(0).frame(width: leftWidth, height: leftWidth * (template.frameShapes.safe(0)?.heightMultiplier ?? 1))
                        imageCell(1).frame(width: leftWidth, height: leftWidth * (template.frameShapes.safe(1)?.heightMultiplier ?? 1))
                    }
                    VStack(spacing: spacing) {
                        imageCell(2).frame(width: rightWidth, height: rightWidth * (template.frameShapes.safe(2)?.heightMultiplier ?? 1))
                        imageCell(3).frame(width: rightWidth, height: rightWidth * (template.frameShapes.safe(3)?.heightMultiplier ?? 1))
                        imageCell(4).frame(width: rightWidth, height: rightWidth * (template.frameShapes.safe(4)?.heightMultiplier ?? 1))
                    }
                }
                .frame(width: width, height: sizes.height)
            }

        default:
            // fallback grid
            let cols = min(template.layoutCount, 3)
            let rows = Int(ceil(Double(template.layoutCount) / Double(cols)))
            let totalSpacing = CGFloat(max(0, cols - 1)) * spacing
            let cellWidth = (width - totalSpacing) / CGFloat(cols)

            // compute per-row max heights
            let rowHeights: [CGFloat] = (0..<rows).map { r in
                (0..<cols).map { c in
                    let idx = r * cols + c
                    if idx < template.layoutCount {
                        return cellWidth * (template.frameShapes.safe(idx)?.heightMultiplier ?? 1)
                    }
                    return CGFloat(0)
                }.max() ?? 0
            }

            let totalHeight = rowHeights.reduce(0, +) + CGFloat(max(0, rows - 1)) * spacing

            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { r in
                    HStack(spacing: spacing) {
                        ForEach(0..<cols, id: \.self) { c in
                            let idx = r * cols + c
                            if idx < template.layoutCount {
                                let h = cellWidth * (template.frameShapes.safe(idx)?.heightMultiplier ?? 1)
                                imageCell(idx).frame(width: cellWidth, height: h)
                            } else {
                                Spacer().frame(width: cellWidth, height: rowHeights[r])
                            }
                        }
                    }
                    .frame(height: rowHeights[r])
                }
            }
            .frame(width: width, height: totalHeight)
        }
    }

    @ViewBuilder
    private func imageCell(_ index: Int) -> some View {
        let shape = template.frameShapes.indices.contains(index) ? template.frameShapes[index] : MemoryAlbumFrameShape.square

        if let aspect = aspectRatio(for: shape) {
            GeometryReader { proxy in
                content(index)
                    .aspectRatio(aspect, contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .overlay(debugOverlay(index: index, width: proxy.size.width, height: proxy.size.height), alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            GeometryReader { proxy in
                content(index)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .overlay(debugOverlay(index: index, width: proxy.size.width, height: proxy.size.height), alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func debugOverlay(index: Int, width: CGFloat, height: CGFloat) -> some View {
        // intentionally empty in UI builds — per-cell debug badges removed for cleaner previews
        EmptyView()
    }

    private func aspectRatio(for shape: MemoryAlbumFrameShape) -> CGFloat? {
        switch shape {
        case .flexible:
            return nil
        default:
            return 1.0 / shape.heightMultiplier
        }
    }

    @ViewBuilder
    private func twoImageLayout(variant: Int) -> some View {
        switch variant {
        case 1:
            VStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                imageCell(1)
            }

                case 2:
            HStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                    .layoutPriority(2)
                imageCell(1)
                    .layoutPriority(1)
                    .frame(minWidth: 44)
            }

        case 3:
            HStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                    .layoutPriority(1)
                    .frame(minWidth: 44)
                imageCell(1)
                    .layoutPriority(2)
            }

        default:
            HStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                imageCell(1)
            }
        }
    }

    @ViewBuilder
    private func threeImageLayout(variant: Int) -> some View {
        switch variant {
        case 1:
            HStack(spacing: MindMorySpacing.sm) {
                VStack(spacing: MindMorySpacing.sm) {
                    imageCell(0)
                    imageCell(1)
                }
                imageCell(2)
            }

        case 2:
            VStack(spacing: MindMorySpacing.sm) {
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(0)
                    imageCell(1)
                }
                imageCell(2)
            }

        case 3:
            VStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(1)
                    imageCell(2)
                }
            }

        default:
            HStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                imageCell(1)
                imageCell(2)
            }
        }
    }

    @ViewBuilder
    private func fourImageLayout(variant: Int) -> some View {
        switch variant {
        case 1:
            HStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                VStack(spacing: MindMorySpacing.sm) {
                    imageCell(1)
                    imageCell(2)
                    imageCell(3)
                }
            }

        case 2:
            HStack(spacing: MindMorySpacing.sm) {
                VStack(spacing: MindMorySpacing.sm) {
                    imageCell(0)
                    imageCell(1)
                }
                VStack(spacing: MindMorySpacing.sm) {
                    imageCell(2)
                    imageCell(3)
                }
            }

        case 3:
            VStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(1)
                    imageCell(2)
                    imageCell(3)
                }
            }

        default:
            VStack(spacing: MindMorySpacing.sm) {
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(0)
                    imageCell(1)
                }
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(2)
                    imageCell(3)
                }
            }
        }
    }

    @ViewBuilder
    private func fiveImageLayout(variant: Int) -> some View {
        switch variant {
        case 1:
            VStack(spacing: MindMorySpacing.sm) {
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(0)
                    imageCell(1)
                    imageCell(2)
                }
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(3)
                    imageCell(4)
                }
            }

        case 2:
            HStack(spacing: MindMorySpacing.sm) {
                VStack(spacing: MindMorySpacing.sm) {
                    imageCell(0)
                    imageCell(1)
                }
                VStack(spacing: MindMorySpacing.sm) {
                    imageCell(2)
                    imageCell(3)
                    imageCell(4)
                }
            }

        case 3:
            HStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                VStack(spacing: MindMorySpacing.sm) {
                    HStack(spacing: MindMorySpacing.sm) {
                        imageCell(1)
                        imageCell(2)
                    }
                    HStack(spacing: MindMorySpacing.sm) {
                        imageCell(3)
                        imageCell(4)
                    }
                }
            }

        case 4:
            VStack(spacing: MindMorySpacing.sm) {
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(0)
                    imageCell(1)
                }
                HStack(spacing: MindMorySpacing.sm) {
                    imageCell(2)
                    imageCell(3)
                    imageCell(4)
                }
            }

        default:
            HStack(spacing: MindMorySpacing.sm) {
                VStack(spacing: MindMorySpacing.sm) {
                    imageCell(0)
                    imageCell(1)
                }
                VStack(spacing: MindMorySpacing.sm) {
                    imageCell(2)
                    imageCell(3)
                    imageCell(4)
                }
            }
        }
    }

    @ViewBuilder
    private func genericGridLayout() -> some View {
        LazyVGrid(columns: template.gridColumns, spacing: MindMorySpacing.sm) {
            ForEach(0..<template.layoutCount, id: \.self) { index in
                imageCell(index)
            }
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    func safe(_ index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
