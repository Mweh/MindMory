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
        ZStack(alignment: .bottomTrailing) {
            PageLayout(
                padding: EdgeInsets(
                    top: MindMorySpacing.lg,
                    leading: MindMorySpacing.xl,
                    bottom: MindMorySpacing.xl,
                    trailing: MindMorySpacing.xl
                )
            ) {
                content
            }

            floatingActionButton
                .padding(.trailing, MindMorySpacing.xl)
                .padding(.bottom, MindMorySpacing.xl)
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
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !viewModel.albums.isEmpty {
            albumList
        } else {
            emptyState
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
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.bottom, MindMorySpacing.lg)

                LazyVStack(spacing: MindMorySpacing.lg) {
                    ForEach(viewModel.albums) { album in
                        albumItem(for: album)
                    }
                }
            }
            .padding(.bottom, 140)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Your albums")
                .font(MindMoryTypography.headline)

            Text("Review recently created albums and add more memories when you are ready.")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }

    private func albumItem(for album: Album) -> some View {
        Button {
            selectedAlbum = album
        } label: {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                if let image = album.coverPhoto?.uiImage {
                    ImagePlaceholder(image: image, imageName: nil)
                        .frame(height: 190)
                        .frame(maxWidth: .infinity)
                } else {
                    ImagePlaceholder(image: nil, imageName: nil)
                        .frame(height: 190)
                        .frame(maxWidth: .infinity)
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text(album.name)
                        .font(MindMoryTypography.titleMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    HStack(spacing: MindMorySpacing.sm) {
                        Spacer()

                        Text(album.photos.isEmpty ? "No photos" : "\(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                    }
                }
                .padding(.top, MindMorySpacing.sm)
            }
                .padding(MindMorySpacing.lg)
                .background(MindMoryColors.Surface.background)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                    .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AlbumListView(viewModel: AlbumListViewModel(albums: PreviewData.sampleAlbums))
}
