import SwiftUI
import UIKit

struct AlbumDetailView: View {
    let album: Album

    var body: some View {
        PageLayout(
            padding: EdgeInsets(
                top: MindMorySpacing.lg,
                leading: MindMorySpacing.xl,
                bottom: MindMorySpacing.xl,
                trailing: MindMorySpacing.xl
            )
        ) {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                header
                sectionList
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                Text(album.name)
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)

                if let image = album.coverPhoto?.uiImage {
                    ImagePlaceholder(image: image, imageName: nil)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                } else {
                    ImagePlaceholder(image: nil, imageName: nil)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                .stroke(MindMoryColors.Border.subtle)
                        )
                }

                HStack(spacing: MindMorySpacing.md) {
                    Spacer()

                    Text(album.photos.isEmpty ? "No photos" : "\(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.link)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .stroke(MindMoryColors.Border.subtle)
        )
    }
}
