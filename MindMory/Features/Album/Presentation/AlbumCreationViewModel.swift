import Combine
import UIKit

class AlbumCreationViewModel: ObservableObject {
    @Published var albumName: String = ""
    @Published var note: String = ""
    @Published private(set) var coverPhoto: AlbumPhoto?
    @Published private(set) var photos: [AlbumPhoto] = []
    @Published var alertMessage: String?
    @Published var savedAlbum: Album?
    @Published private(set) var isProcessing: Bool = false

    let category: AlbumCategory
    let loadAlbumPhotosUseCase: LoadAlbumPhotosUseCase
    let createAlbumUseCase: CreateAlbumUseCase
    private var albumRepository: AlbumRepositoryProtocol?
    private var existingAlbum: Album?
    var photoLoadingTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?

    var isEditMode: Bool {
        existingAlbum != nil
    }

    var isSaveButtonDisabled: Bool {
        guard coverPhoto != nil else { return true }
        return albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing
    }

    var albumSummary: String? {
        guard let album = savedAlbum else { return nil }
        return "Album \(album.name) \(isEditMode ? "updated" : "created") with \(album.photos.count) photo\(album.photos.count == 1 ? "" : "s")."
    }

    func albumSections() -> [MemoryAlbumSection] {
        []
    }

    func buildAlbumPhotos() -> [AlbumPhoto] {
        var albumPhotos: [AlbumPhoto] = []
        if let coverPhoto = coverPhoto {
            albumPhotos.append(coverPhoto)
        }
        albumPhotos.append(contentsOf: photos)
        return albumPhotos
    }

    init(
        category: AlbumCategory,
        loadAlbumPhotosUseCase: LoadAlbumPhotosUseCase = LoadAlbumPhotosUseCase(),
        createAlbumUseCase: CreateAlbumUseCase = CreateAlbumUseCase(),
        albumRepository: AlbumRepositoryProtocol? = nil
    ) {
        self.category = category
        self.loadAlbumPhotosUseCase = loadAlbumPhotosUseCase
        self.createAlbumUseCase = createAlbumUseCase
        self.albumRepository = albumRepository
    }

    func configure(repository: AlbumRepositoryProtocol) {
        self.albumRepository = repository
    }

    func configureForEditing(_ album: Album) {
        existingAlbum = album
        albumName = album.name
        note = album.note
        coverPhoto = album.coverPhoto
        photos = Array(album.photos.dropFirst())
        savedAlbum = nil
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
        guard !isProcessing else { return }
        isProcessing = true

        saveTask?.cancel()
        saveTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                let album = try self.createAlbumUseCase.execute(
                    name: self.albumName,
                    note: self.note,
                    photos: self.buildAlbumPhotos(),
                    sections: self.albumSections(),
                    category: self.category,
                    id: self.existingAlbum?.id,
                    createdAt: self.existingAlbum?.createdAt
                )

                if let repository = self.albumRepository {
                    try await repository.save(album)
                }

                await MainActor.run {
                    self.savedAlbum = album
                    self.presentAlert("\(album.name) is ready. Your album has been \(self.isEditMode ? "updated" : "created").")
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.presentAlert(error.localizedDescription)
                    self.isProcessing = false
                }
            }
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
        saveTask?.cancel()
    }
}
