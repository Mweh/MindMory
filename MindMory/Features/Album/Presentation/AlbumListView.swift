import SwiftUI
import SwiftData

struct AlbumListView: View {
    @StateObject private var viewModel: AlbumListViewModel
    @State private var isShowingCreateAlbum = false
    @State private var selectedAlbum: Album?
    @Environment(\.modelContext) private var modelContext

    init(viewModel: AlbumListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var albumRepository: AlbumRepository {
        AlbumRepository(context: modelContext)
    }

    var body: some View {
        CustomAlbumLayout(
            padding: EdgeInsets(
                top: MindMorySpacing.lg,
                leading: MindMorySpacing.xl,
                bottom: MindMorySpacing.xl,
                trailing: MindMorySpacing.xl
            )
        ) {
            content
        }
        .navigationDestination(isPresented: $isShowingCreateAlbum) {
            MemoryAlbumCreationView(
                viewModel: MemoryAlbumCreationViewModel(albumRepository: albumRepository)
            ) { album in
                viewModel.addAlbum(album)
            }
        }
        .navigationDestination(item: $selectedAlbum) { album in
            AlbumDetailView(
                album: album,
                onEdit: { updatedAlbum in
                    viewModel.updateAlbum(updatedAlbum)
                    selectedAlbum = updatedAlbum
                },
                onDelete: {
                    viewModel.removeAlbum(id: album.id)
                    selectedAlbum = nil
                }
            )
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(repository: albumRepository)
        }
        .alert("Albums", isPresented: alertBinding) {
            Button("OK", role: .cancel) {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { isPresented in
                if !isPresented { viewModel.dismissAlert() }
            }
        )
    }

    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.bottom, MindMorySpacing.lg)

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 220)
                } else if !viewModel.albums.isEmpty {
                    albumList
                } else {
                    emptyState
                }
            }
            .padding(.bottom, 140)
        }
    }

    private var floatingActionButton: some View {
        Button {
            isShowingCreateAlbum = true
        } label: {
            Image(systemName: "plus")
                .font(MindMoryTypography.labelLarge)
                .foregroundColor(MindMoryColors.Content.inverse)
                .frame(width: 56, height: 56)
                .background(MindMoryColors.Surface.primary)
                .clipShape(Circle())
                .shadow(color: MindMoryColors.Content.primary.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create album")
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
        VStack(alignment: .leading, spacing: 0) {
            AlbumPromoCardView(totalAlbums: viewModel.albums.count) {
                isShowingCreateAlbum = true
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, MindMorySpacing.lg)

            LazyVStack(spacing: MindMorySpacing.lg) {
                ForEach(viewModel.albums) { album in
                    albumItem(for: album)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Your albums")
                .font(MindMoryTypography.displayLevel)
                .foregroundStyle(MindMoryColors.Content.primary)

            Text("Review recently created albums and add more memories when you are ready.")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }

    private func albumItem(for album: Album) -> some View {
        Button {
            selectedAlbum = album
        } label: {
            ZStack(alignment: .bottomLeading) {
                albumCoverImage(for: album)
                    .frame(height: 230)
                    .frame(maxWidth: .infinity)
                    .overlay(albumCoverGradient)
                    .clipped()

                albumImageOverlay(for: album)
                    .padding(MindMorySpacing.lg)
            }
            .background(MindMoryColors.Surface.surface)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                    .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
            )
            .shadow(color: MindMoryShadow.cardColor, radius: MindMoryShadow.softRadius, x: 0, y: MindMoryShadow.softY)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func albumCoverImage(for album: Album) -> some View {
        if let image = album.coverPhoto?.uiImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            albumCoverPlaceholder
        }
    }

    private var albumCoverPlaceholder: some View {
        ZStack {
            MindMoryColors.Surface.surface

            VStack(spacing: MindMorySpacing.sm) {
                Image(systemName: "photo")
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                    .padding(MindMorySpacing.lg)
                    .background(
                        Circle()
                            .fill(MindMoryColors.Surface.background)
                    )

                Text("Album cover")
                    .font(MindMoryTypography.titleSmall)
                    .foregroundStyle(MindMoryColors.Content.primary)
            }
        }
    }

    private var albumCoverGradient: some View {
        LinearGradient(
            colors: [Color.black.opacity(0.46), Color.black.opacity(0.15), .clear],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    private func albumImageOverlay(for album: Album) -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            HStack(spacing: MindMorySpacing.sm) {
                Badge(
                    iconName: "photo.on.rectangle",
                    text: album.photos.isEmpty ? "No photos" : "\(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")",
                    tint: MindMoryColors.Content.inverse,
                    style: .iconText,
                    cornerRadius: MindMoryRadius.pill
                )
                Spacer()

                Text("Album")
                    .font(MindMoryTypography.labelSmall)
                    .foregroundStyle(MindMoryColors.Content.inverse)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.black.opacity(0.32))
                    .clipShape(Capsule())
            }

            Spacer()

            Text(album.name)
                .font(MindMoryTypography.titleLarge)
                .fontWeight(.semibold)
                .foregroundStyle(MindMoryColors.Content.inverse)
                .lineLimit(2)
                .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AlbumListView(viewModel: AlbumListViewModel(albums: PreviewData.sampleAlbums))
}
