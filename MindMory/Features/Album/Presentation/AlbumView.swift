import SwiftUI

struct AlbumView: View {
    @StateObject private var viewModel: AlbumListViewModel
    @State private var isShowingCreateAlbum = false

    init(viewModel: AlbumListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                content
                    .padding(.horizontal, MindMorySpacing.xl)
                    .padding(.top, MindMorySpacing.lg)
            }
            .navigationDestination(isPresented: $isShowingCreateAlbum) {
                AlbumCategorySelectionView(
                    timelineDestination: TimelineAlbumCreateView(viewModel: TimelineAlbumViewModel()) { album in
                        viewModel.addAlbum(album)
                    },
                    memoryDestination: MemoryAlbumCreateView(viewModel: MemoryAlbumViewModel()) { album in
                        viewModel.addAlbum(album)
                    }
                )
            }
            .background(MindMoryColors.background.ignoresSafeArea())
            .navigationTitle("Album")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingCreateAlbum = true
                    } label: {
                        Label("New Album", systemImage: "plus")
                            .font(MindMoryTypography.button)
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
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                HStack(alignment: .top, spacing: MindMorySpacing.md) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                        Text(album.name)
                            .font(MindMoryTypography.headingMedium)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        Text(album.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(MindMoryTypography.caption)
                            .foregroundStyle(MindMoryColors.textSecondary)
                    }

                    Spacer()

                    Text(album.category == .timeline ? "Timeline" : "Memory")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(album.category == .timeline ? MindMoryColors.primaryGreen : MindMoryColors.mutedIndigo)
                        .padding(.horizontal, MindMorySpacing.sm)
                        .padding(.vertical, MindMorySpacing.xs)
                        .background(album.category == .timeline ? MindMoryColors.surface : MindMoryColors.surfaceStrong)
                        .clipShape(Capsule())

                    Text("\(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.primaryGreen)
                }

                if let image = album.photos.first?.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(MindMoryRadius.large)
                }

                if !album.note.isEmpty {
                    Text(album.note)
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.textSecondary)
                        .lineLimit(3)
                }
            }
        }
    }
}

#Preview {
    AlbumView(viewModel: AlbumListViewModel())
}
