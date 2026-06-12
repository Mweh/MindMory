import SwiftUI
import SwiftData

struct AlbumListView: View {
    @StateObject private var viewModel: AlbumListViewModel
    @State private var isShowingCreateAlbum = false
    @Environment(\.modelContext) private var modelContext

    init(viewModel: AlbumListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var albumRepository: AlbumRepository {
        AlbumRepository(context: modelContext)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            content
                .padding(.horizontal, MindMorySpacing.xl)
                .padding(.top, MindMorySpacing.lg)

            floatingActionButton
                .padding(.trailing, MindMorySpacing.xl)
                .padding(.bottom, MindMorySpacing.xl)

            // Use navigationDestination with isPresented to trigger navigation from a NavigationStack
        }
        .navigationDestination(isPresented: $isShowingCreateAlbum) {
            MemoryAlbumCreationView(
                viewModel: MemoryAlbumCreationViewModel(albumRepository: albumRepository)
            ) { album in
                viewModel.addAlbum(album)
            }
        }
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.configure(repository: albumRepository)
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

    private var floatingActionButton: some View {
        Button {
            isShowingCreateAlbum = true
        } label: {
            Image(systemName: "plus")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(MindMoryColors.primaryGreen)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
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
                    MemoryImagePlaceholderView(image: image, imageName: nil)
                        .frame(height: 190)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                } else {
                    MemoryImagePlaceholderView(image: nil, imageName: nil)
                        .frame(height: 190)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                                .stroke(MindMoryColors.border)
                        )
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text(album.name)
                        .font(MindMoryTypography.headingMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    HStack(spacing: MindMorySpacing.sm) {
                        Text(album.albumDate.displayText)
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
    AlbumListView(viewModel: AlbumListViewModel(albums: PreviewData.sampleAlbums))
}
