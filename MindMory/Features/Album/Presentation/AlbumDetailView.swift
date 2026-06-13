import SwiftUI

struct AlbumDetailView: View {
    let album: Album

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                header
                sectionList
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, MindMorySpacing.xl)
            .padding(.vertical, MindMorySpacing.lg)
        }
        .background(MindMoryColors.Surface.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        AlbumHeaderCardView(
            name: album.name,
            coverPhoto: album.coverPhoto?.uiImage,
            albumDateText: album.albumDate.displayText,
            photoCountText: album.photos.isEmpty ? "No photos" : "\(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")"
        )
    }

    private var sectionList: some View {
        VStack(spacing: MindMorySpacing.md) {
            if album.sections.isEmpty {
                noSections
            } else {
                ForEach(Array(album.sections.enumerated()), id: \.element.id) { _, section in
                    sectionCard(for: section)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func sectionCard(for section: MemoryAlbumSection) -> some View {
        MemoryAlbumSectionView(section: section, isPreview: false) { index, section in
            AlbumSectionPhotoCell(image: imageForSectionCell(index: index, section: section))
        }
    }

    private func imageForSectionCell(index: Int, section: MemoryAlbumSection) -> UIImage? {
        guard case .image(_, _, let photos) = section.content else { return nil }
        guard photos.indices.contains(index), let photo = photos[index] else { return nil }
        return photo.uiImage
    }

    private var noSections: some View {
        VStack(alignment: .center, spacing: MindMorySpacing.sm) {
            Text("No album layout available yet.")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)

            Text("Create or open an album with image and text sections to see memories in a beautiful layout.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(MindMorySpacing.lg)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                .stroke(MindMoryColors.Border.subtle)
        )
    }
}
