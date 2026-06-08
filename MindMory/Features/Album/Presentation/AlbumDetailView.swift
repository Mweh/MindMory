import SwiftUI

struct AlbumDetailView: View {
    let album: Album

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindMorySpacing.xl) {
                header
                sectionList
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, MindMorySpacing.xl)
            .padding(.vertical, MindMorySpacing.lg)
        }
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text(album.name)
                    .font(MindMoryTypography.headingLarge)
                    .foregroundStyle(MindMoryColors.textPrimary)

                if let coverPhoto = album.coverPhoto?.uiImage {
                    Image(uiImage: coverPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(MindMoryRadius.large)
                } else {
                    RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                        .fill(MindMoryColors.surface)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(MindMoryColors.textSecondary)
                        )
                }

                HStack(spacing: MindMorySpacing.md) {
                    Text(album.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    Spacer()

                    Text(album.photos.isEmpty ? "No photos" : "\(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.primaryGreen)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var sectionList: some View {
        VStack(spacing: MindMorySpacing.lg) {
            if album.sections.isEmpty {
                noSections
            } else {
                ForEach(album.sections) { section in
                    sectionCard(for: section)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func sectionCard(for section: MemoryAlbumSection) -> some View {
        switch section.content {
        case .image:
            imageSection(for: section)
        case .text(let textSection):
            textSectionCard(textSection)
        }
    }

    @ViewBuilder
    private func imageSection(for section: MemoryAlbumSection) -> some View {
        if let layoutCount = section.layoutCount, let layoutVariant = section.layoutVariant {
            let template = MemoryAlbumSectionLayoutCatalog.template(layoutCount: layoutCount, variant: layoutVariant)

            if template.isOverlayStyle {
                overlappedImageSection(section, template: template)
                    .frame(height: template.albumHeight)
                    .frame(maxWidth: .infinity)
            } else {
                MemoryAlbumSectionLayoutRenderer(template: template) { photoIndex in
                    detailImageCell(at: photoIndex, in: section)
                }
                .frame(height: template.albumHeight)
                .frame(maxWidth: .infinity)
            }
        } else {
            EmptyView()
        }
    }

    private func textSectionCard(_ textSection: MemoryAlbumTextSection) -> some View {
        MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: false)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func detailImageCell(at index: Int, in section: MemoryAlbumSection) -> some View {
        let shape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

        if let image = imageForSectionCell(index: index, section: section) {
            GeometryReader { geometry in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .clipShape(shape)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Color(MindMoryColors.surface)
                .clipShape(shape)
                .overlay(
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(MindMoryColors.textSecondary)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func imageForSectionCell(index: Int, section: MemoryAlbumSection) -> UIImage? {
        guard case .image(_, _, let photos) = section.content else { return nil }
        guard photos.indices.contains(index), let photo = photos[index] else { return nil }
        return photo.uiImage
    }

    private func overlappedImageSection(_ section: MemoryAlbumSection, template: MemoryAlbumSectionLayoutTemplate) -> some View {
        GeometryReader { geometry in
            let size = geometry.size
            let widthFactor: CGFloat = template.layoutCount <= 3 ? 0.72 : 0.58
            let cardWidth = size.width * widthFactor
            let cardHeight = size.height * 0.82
            let positions = overlayPositions(for: template.layoutCount, in: size)
            let rotations = overlayRotations(for: template.layoutCount)

            ZStack {
                ForEach(0..<template.layoutCount, id: \.self) { index in
                    let card = detailImageCell(at: index, in: section)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                        .rotationEffect(rotations[index])
                        .offset(positions[index])
                        .zIndex(Double(index))

                    card
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }

    private func overlayPositions(for layoutCount: Int, in size: CGSize) -> [CGSize] {
        let baseX = size.width * 0.12
        let baseY = size.height * 0.05

        switch layoutCount {
        case 2:
            return [CGSize(width: -baseX * 1.1, height: baseY * 1.4), CGSize(width: baseX * 1.2, height: -baseY)]
        case 3:
            return [CGSize(width: -baseX * 1.4, height: baseY * 1.3), CGSize(width: 0, height: -baseY * 1.5), CGSize(width: baseX * 1.6, height: baseY * 1.1)]
        case 4:
            return [CGSize(width: -baseX * 1.7, height: baseY * 1.2), CGSize(width: -baseX * 0.2, height: -baseY * 1.4), CGSize(width: baseX * 0.8, height: baseY * 0.8), CGSize(width: baseX * 1.8, height: baseY * 1.6)]
        case 5:
            return [CGSize(width: -baseX * 1.8, height: baseY * 1.4), CGSize(width: -baseX * 0.6, height: -baseY * 1.3), CGSize(width: 0, height: baseY * 0.1), CGSize(width: baseX * 1.1, height: baseY * 1.1), CGSize(width: baseX * 1.9, height: -baseY * 0.3)]
        default:
            return Array(repeating: .zero, count: layoutCount)
        }
    }

    private func overlayRotations(for count: Int) -> [Angle] {
        switch count {
        case 2:
            return [.degrees(-12), .degrees(10)]
        case 3:
            return [.degrees(-14), .degrees(6), .degrees(-8)]
        case 4:
            return [.degrees(-16), .degrees(8), .degrees(-6), .degrees(12)]
        case 5:
            return [.degrees(-16), .degrees(10), .degrees(-4), .degrees(8), .degrees(-10)]
        default:
            return Array(repeating: .degrees(0), count: count)
        }
    }

    private var noSections: some View {
        VStack(alignment: .center, spacing: MindMorySpacing.sm) {
            Text("No album layout available yet.")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.textSecondary)

            Text("Create or open an album with image and text sections to see memories in a beautiful layout.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(MindMorySpacing.lg)
        .background(MindMoryColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                .stroke(MindMoryColors.border)
        )
    }
}
