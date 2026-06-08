import SwiftUI

struct AlbumView: View {
    @StateObject private var viewModel: AlbumListViewModel
    @State private var isShowingCreateAlbum = false

    init(viewModel: AlbumListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .padding(.horizontal, MindMorySpacing.xl)
                .padding(.top, MindMorySpacing.lg)
                .navigationDestination(isPresented: $isShowingCreateAlbum) {
                    MemoryAlbumCreateView(viewModel: MemoryAlbumViewModel()) { album in
                        viewModel.addAlbum(album)
                    }
                }
                .background(MindMoryColors.background.ignoresSafeArea())
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isShowingCreateAlbum = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.albums.isEmpty {
            emptyState
        } else {
            albumList
        }
    }

    private var emptyState: some View {
        VStack(spacing: MindMorySpacing.xxxl) {
            Spacer()

            EmptyStateView(
                title: "No albums yet",
                message: "Create your first album to keep photo memories organized and easy to revisit."
            )

            PrimaryButton(title: "Create Album") {
                isShowingCreateAlbum = true
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var albumList: some View {
        ScrollView {
            LazyVStack(spacing: MindMorySpacing.lg) {
                headerSection

                ForEach(viewModel.albums) { album in
                    albumItem(for: album)
                }
            }
            .padding(.bottom, 120)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Your albums")
                .font(MindMoryTypography.displayLarge)

            Text("Review recently created albums and add more memories when you are ready.")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.textSecondary)
        }
    }

    private func albumItem(for album: Album) -> some View {
        NavigationLink(destination: AlbumDetailView(album: album)) {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                if let image = album.coverPhoto?.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 190)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(MindMoryRadius.large)
                } else {
                    RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                        .fill(MindMoryColors.surface)
                        .frame(height: 190)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundStyle(MindMoryColors.textSecondary)
                        )
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text(album.name)
                        .font(MindMoryTypography.headingMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    HStack(spacing: MindMorySpacing.sm) {
                        Text(album.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(MindMoryTypography.caption)
                            .foregroundStyle(MindMoryColors.textSecondary)

                        Spacer()

                        Text(album.photos.isEmpty ? "No photos" : "\(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")")
                            .font(MindMoryTypography.caption)
                            .foregroundStyle(MindMoryColors.textSecondary)
                    }
                }
                .padding(.top, MindMorySpacing.sm)
            }
            .padding(MindMorySpacing.lg)
            .background(MindMoryColors.background)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                    .stroke(MindMoryColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AlbumView(viewModel: AlbumListViewModel(albums: PreviewData.sampleAlbums))
}
