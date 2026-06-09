import Combine
import UIKit

class AlbumCreationViewModel: ObservableObject {
    @Published var albumName: String = ""
    @Published var note: String = ""
    @Published private(set) var coverPhoto: AlbumPhoto?
    @Published private(set) var photos: [AlbumPhoto] = []
    @Published var alertMessage: String?
    @Published var savedAlbum: Album?

    @Published var isDateRange: Bool = false
    @Published var albumDateStart: Date = Date()
    @Published var albumDateEnd: Date = Date()

    let category: AlbumCategory
    private let loadAlbumPhotosUseCase: LoadAlbumPhotosUseCase
    let createAlbumUseCase: CreateAlbumUseCase
    private var photoLoadingTask: Task<Void, Never>?

    var isSaveButtonDisabled: Bool {
        guard coverPhoto != nil else { return true }
        return albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var albumDate: AlbumDate {
        AlbumDate(
            start: albumDateStart,
            end: isDateRange ? albumDateEnd : albumDateStart
        )
    }

    var dateRangeIsValid: Bool {
        !isDateRange || albumDateEnd >= albumDateStart
    }

    var albumSummary: String? {
        guard let album = savedAlbum else { return nil }
        return "Album \(album.name) created with \(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")."
    }

    init(
        category: AlbumCategory,
        loadAlbumPhotosUseCase: LoadAlbumPhotosUseCase = LoadAlbumPhotosUseCase(),
        createAlbumUseCase: CreateAlbumUseCase = CreateAlbumUseCase()
    ) {
        self.category = category
        self.loadAlbumPhotosUseCase = loadAlbumPhotosUseCase
        self.createAlbumUseCase = createAlbumUseCase
    }

    func updateCoverPhoto(from imageData: [Data]) {
        photoLoadingTask?.cancel()
        savedAlbum = nil

        photoLoadingTask = Task { [weak self] in
            guard let self = self else { return }
            if Task.isCancelled { return }

            let loadedPhotos = await self.loadAlbumPhotosUseCase.execute(from: imageData)

            await MainActor.run {
                self.coverPhoto = loadedPhotos.first

                if !imageData.isEmpty, self.coverPhoto == nil {
                    self.presentAlert("Unable to load the selected cover photo. Please try again.")
                }
            }
        }
    }

    func updateSelectedPhotos(from imageData: [Data]) {
        photoLoadingTask?.cancel()
        savedAlbum = nil

        photoLoadingTask = Task { [weak self] in
            guard let self = self else { return }
            if Task.isCancelled { return }

            let loadedPhotos = await self.loadAlbumPhotosUseCase.execute(from: imageData)

            await MainActor.run {
                self.photos = loadedPhotos

                if !imageData.isEmpty && loadedPhotos.isEmpty {
                    self.presentAlert("Unable to load selected images. Please try again.")
                }
            }
        }
    }

    func saveAlbum() {
        do {
            var albumPhotos = [AlbumPhoto]()
            if let coverPhoto = coverPhoto {
                albumPhotos.append(coverPhoto)
            }
            albumPhotos.append(contentsOf: photos)

            let album = try createAlbumUseCase.execute(
                name: albumName,
                note: note,
                photos: albumPhotos,
                category: category
            )

            savedAlbum = album
            presentAlert("\(album.name) is ready. Your album has been created.")
        } catch {
            presentAlert(error.localizedDescription)
        }
    }

    func removePhoto(id: UUID) {
        photos.removeAll { $0.id == id }
    }

    func dismissAlert() {
        alertMessage = nil
    }

    func presentAlert(_ message: String) {
        alertMessage = message
    }

    deinit {
        photoLoadingTask?.cancel()
    }
}
