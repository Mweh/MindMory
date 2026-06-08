import Foundation

final class TimelineAlbumViewModel: AlbumCreationViewModel {
    init(
        loadAlbumPhotosUseCase: LoadAlbumPhotosUseCase = LoadAlbumPhotosUseCase(),
        createAlbumUseCase: CreateAlbumUseCase = CreateAlbumUseCase()
    ) {
        super.init(category: .timeline, loadAlbumPhotosUseCase: loadAlbumPhotosUseCase, createAlbumUseCase: createAlbumUseCase)
    }
}
