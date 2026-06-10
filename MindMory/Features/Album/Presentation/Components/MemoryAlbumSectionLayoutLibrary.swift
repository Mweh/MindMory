import SwiftUI

struct MemoryAlbumSectionLayoutTemplate: Identifiable, Equatable {
    let id: String
    let layoutCount: Int
    let variant: Int
    let title: String
    let albumHeight: CGFloat
    let gridColumns: [GridItem]

    init(layoutCount: Int, variant: Int, title: String, albumHeight: CGFloat, gridColumns: [GridItem]) {
        self.id = "album-layout-\(layoutCount)-\(variant)"
        self.layoutCount = layoutCount
        self.variant = variant
        self.title = title
        self.albumHeight = albumHeight
        self.gridColumns = gridColumns
    }
}

enum MemoryAlbumSectionLayoutCatalog {
    static func template(layoutCount: Int, variant: Int) -> MemoryAlbumSectionLayoutTemplate {
        templates(for: layoutCount).first(where: { $0.variant == variant }) ?? templates(for: layoutCount).first!
    }

    static func templates(for layoutCount: Int) -> [MemoryAlbumSectionLayoutTemplate] {
        let height = defaultAlbumHeight(for: layoutCount)

        switch layoutCount {
        case 1:
            return [
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 1,
                    variant: 0,
                    title: "Single image",
                    albumHeight: height,
                    gridColumns: [.init(.flexible())]
                )
            ]

        case 2:
            return [
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 2,
                    variant: 0,
                    title: "Side-by-side",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 2)
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 2,
                    variant: 1,
                    title: "Stacked vertical",
                    albumHeight: height,
                    gridColumns: [.init(.flexible())]
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 2,
                    variant: 2,
                    title: "Focused split",
                    albumHeight: height,
                    gridColumns: [.init(.flexible()), .init(.flexible())]
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 2,
                    variant: 3,
                    title: "Reverse focus",
                    albumHeight: height,
                    gridColumns: [.init(.flexible()), .init(.flexible())]
                )
            ]

        case 3:
            return [
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 3,
                    variant: 0,
                    title: "Three across",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3)
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 3,
                    variant: 1,
                    title: "Large left + stacked",
                    albumHeight: height,
                    gridColumns: [.init(.flexible()), .init(.flexible())]
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 3,
                    variant: 2,
                    title: "Top row + wide bottom",
                    albumHeight: height,
                    gridColumns: [.init(.flexible()), .init(.flexible())]
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 3,
                    variant: 3,
                    title: "Large top + split bottom",
                    albumHeight: height,
                    gridColumns: [.init(.flexible()), .init(.flexible())]
                )
            ]

        case 4:
            return [
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 4,
                    variant: 0,
                    title: "Squared grid",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 2)
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 4,
                    variant: 1,
                    title: "Tall left + stack",
                    albumHeight: height,
                    gridColumns: [.init(.flexible()), .init(.flexible())]
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 4,
                    variant: 2,
                    title: "Mixed split",
                    albumHeight: height,
                    gridColumns: [.init(.flexible()), .init(.flexible())]
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 4,
                    variant: 3,
                    title: "Full-width top",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3)
                )
            ]

        case 5:
            return [
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 5,
                    variant: 0,
                    title: "2x3 mosaic",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3)
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 5,
                    variant: 1,
                    title: "Three top + two bottom",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3)
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 5,
                    variant: 2,
                    title: "Split focus",
                    albumHeight: height,
                    gridColumns: [.init(.flexible()), .init(.flexible()), .init(.flexible())]
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 5,
                    variant: 3,
                    title: "Column focus",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3)
                ),
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: 5,
                    variant: 4,
                    title: "Two plus three",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: 3)
                )
            ]

        default:
            return [
                MemoryAlbumSectionLayoutTemplate(
                    layoutCount: layoutCount,
                    variant: 0,
                    title: "Grid",
                    albumHeight: height,
                    gridColumns: Array(repeating: .init(.flexible(), spacing: MindMorySpacing.sm), count: min(layoutCount, 3))
                )
            ]
        }
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

struct MemoryAlbumSectionLayoutRenderer<Content: View>: View {
    let template: MemoryAlbumSectionLayoutTemplate
    let content: (Int) -> Content

    var body: some View {
        switch template.layoutCount {
        case 1:
            content(0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case 2:
            twoImageLayout(variant: template.variant)

        case 3:
            threeImageLayout(variant: template.variant)

        case 4:
            fourImageLayout(variant: template.variant)

        case 5:
            fiveImageLayout(variant: template.variant)

        default:
            genericGridLayout()
        }
    }

    @ViewBuilder
    private func imageCell(_ index: Int) -> some View {
        content(index)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
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
                    .frame(minWidth: 100)
            }

        case 3:
            HStack(spacing: MindMorySpacing.sm) {
                imageCell(0)
                    .layoutPriority(1)
                    .frame(minWidth: 100)
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
