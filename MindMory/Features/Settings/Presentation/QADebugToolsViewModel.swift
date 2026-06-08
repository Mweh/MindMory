import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class QADebugToolsViewModel: ObservableObject {

    @Published var skipOnboarding: Bool {
        didSet { repository.hasCompletedOnboarding = skipOnboarding }
    }
    @Published private(set) var selectedImageURL: URL?
    @Published var statusMessage: String?

    private let repository: QADebugSettingsRepositoryProtocol
    private let imageStorageService: DebugImageStorageService

    init(
        repository: QADebugSettingsRepositoryProtocol,
        imageStorageService: DebugImageStorageService
    ) {
        self.repository = repository
        self.imageStorageService = imageStorageService
        self.skipOnboarding = repository.hasCompletedOnboarding
        self.selectedImageURL = imageStorageService.imageURL(
            path: repository.debugHomeCardImagePath
        )
    }

    func resetOnboarding() {
        skipOnboarding = false
        repository.hasCompletedOnboarding = false
        statusMessage = "Onboarding will appear again after relaunch."
    }

    func importPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                statusMessage = "Could not read the selected photo."
                return
            }

            let previousPath = repository.debugHomeCardImagePath
            let path = try imageStorageService.saveHomeCardImage(data: data)
            repository.debugHomeCardImagePath = path
            imageStorageService.removeImage(path: previousPath == path ? nil : previousPath)
            selectedImageURL = imageStorageService.imageURL(path: path)
            NotificationCenter.default.post(name: .qaDebugHomeCardImageDidChange, object: nil)
            statusMessage = "Home card photo updated."
        } catch {
            statusMessage = "Could not import photo. Please try again."
        }
    }

    func resetHomeCardPhoto() {
        imageStorageService.removeImage(path: repository.debugHomeCardImagePath)
        repository.debugHomeCardImagePath = nil
        selectedImageURL = nil
        NotificationCenter.default.post(name: .qaDebugHomeCardImageDidChange, object: nil)
        statusMessage = "Home card photo reset to default."
    }
}

extension Notification.Name {
    static let qaDebugHomeCardImageDidChange = Notification.Name("qaDebugHomeCardImageDidChange")
}
