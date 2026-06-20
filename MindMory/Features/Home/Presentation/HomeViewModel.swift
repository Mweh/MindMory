import Combine
import SwiftUI
import UIKit

struct MemoriesHeaderCopy: Equatable {
    let title: String
    let subtitle: String
}

enum HomePhotoState: Equatable {
    case loading
    case loaded
    case empty(title: String, subtitle: String)
    case permissionRequired(HomePermissionKind)
    case error(String)
}

enum HomePermissionKind: Equatable {
    case location
    case photoLibrary
}

enum MemoryCardSide: Equatable {
    case front
    case back
}

private enum HomePhotoLoadResult {
    case success(String)
    case noPhotos
    case permissionRequired
    case failure(String)
}

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var photoState: HomePhotoState = .loading
    @Published private(set) var focusedMemory: Memory?
    @Published private(set) var selectedAssetLocalIdentifier: String?
    @Published var cardSide: MemoryCardSide = .front
    @Published var captionText = ""
    @Published var homeCardState: HomeCardState = .normal
    @Published var isShowingSharePreview = false

    private let fetchRecentLocationPhotoUseCase: FetchRecentLocationPhotoUseCase?
    private let getCurrentLocationUseCase: GetCurrentLocationUseCase?
    private let qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    private var loadTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    var focusedImageSource: MemoryImageSource {
        if let selectedAssetLocalIdentifier {
            return .assetLocalIdentifier(selectedAssetLocalIdentifier)
        }
        return focusedMemory?.imageSource ?? .placeholder
    }

    var headerCopy: MemoriesHeaderCopy {
        switch photoState {
        case .loaded:
            return MemoriesHeaderCopy(
                title: "A recent photo from this location",
                subtitle: "Latest photo within 1 km of where you are now."
            )
        case .empty:
            return MemoriesHeaderCopy(
                title: "No nearby photos found.",
                subtitle: "MindMory is ready to show a photo from your current location."
            )
        case .permissionRequired(.photoLibrary):
            return MemoriesHeaderCopy(
                title: "Allow photo access",
                subtitle: "Let MindMory show a nearby photo from your gallery."
            )
        case .permissionRequired(.location):
            return MemoriesHeaderCopy(
                title: "Enable location access",
                subtitle: "MindMory uses your current location to surface a nearby photo."
            )
        case .error:
            return MemoriesHeaderCopy(
                title: "Photo discovery failed.",
                subtitle: "Something went wrong while loading a nearby photo."
            )
        case .loading:
            return MemoriesHeaderCopy(
                title: "Finding a photo near you.",
                subtitle: "Searching your gallery for the latest photo taken within 1 km."
            )
        }
    }

    init(
        fetchRecentLocationPhotoUseCase: FetchRecentLocationPhotoUseCase? = nil,
        getCurrentLocationUseCase: GetCurrentLocationUseCase? = nil,
        qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    ) {
        self.fetchRecentLocationPhotoUseCase = fetchRecentLocationPhotoUseCase
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
        self.qaDebugSettingsRepository = qaDebugSettingsRepository

        NotificationCenter.default.publisher(for: .qaDebugHomeCardStateDidChange)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refreshHomeCardState()
                }
            }
            .store(in: &cancellables)
    }

    func load() {
        guard loadTask == nil else { return }
        refreshHomeCardState()
        loadTask = Task { [weak self] in
            await self?.loadPhotoFromCurrentLocation()
        }
    }

    func flipCard() {
        cardSide = cardSide == .front ? .back : .front
    }

    func showSharePreview() {
        isShowingSharePreview = true
    }

    func dismissSharePreview() {
        isShowingSharePreview = false
    }

    func didTapAllowAccess() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadPhotoFromCurrentLocation()
        }
    }

    func retryContextualDiscovery() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadPhotoFromCurrentLocation()
        }
    }

    private func loadPhotoFromCurrentLocation() async {
        await MainActor.run {
            photoState = .loading
        }

        let currentLocation: CurrentLocationContext?
        if let locationUseCase = getCurrentLocationUseCase {
            currentLocation = try? await locationUseCase.execute()
        } else {
            currentLocation = nil
        }

        guard let currentLocation = currentLocation else {
            await MainActor.run {
                photoState = .permissionRequired(.location)
                loadTask = nil
            }
            return
        }

        let loadResult = await loadPhotoAsset(near: currentLocation)

        await MainActor.run {
            switch loadResult {
            case .success(let assetLocalIdentifier):
                selectedAssetLocalIdentifier = assetLocalIdentifier
                focusedMemory = makeFocusedMemory(for: assetLocalIdentifier, locationName: currentLocation.placemarkName)
                photoState = .loaded
            case .noPhotos:
                photoState = .empty(
                    title: "No nearby photo found.",
                    subtitle: "Try moving closer to a place where you took a photo."
                )
                focusedMemory = nil
                selectedAssetLocalIdentifier = nil
            case .permissionRequired:
                photoState = .permissionRequired(.photoLibrary)
                focusedMemory = nil
                selectedAssetLocalIdentifier = nil
            case .failure(let message):
                photoState = .error(message)
                focusedMemory = nil
                selectedAssetLocalIdentifier = nil
            }
            loadTask = nil
        }
    }

    private func loadPhotoAsset(near location: CurrentLocationContext) async -> HomePhotoLoadResult {
        guard let useCase = fetchRecentLocationPhotoUseCase else {
            return .failure("Location photo feature is unavailable.")
        }

        let photoStatus = await useCase.authorizationStatus()
        switch photoStatus {
        case .granted:
            break
        case .notDetermined:
            let requestStatus = await useCase.requestAuthorization()
            if requestStatus != .granted {
                return .permissionRequired
            }
        case .denied:
            return .permissionRequired
        }

        do {
            if let assetLocalIdentifier = try await useCase.execute(near: location) {
                return .success(assetLocalIdentifier)
            }
            return .noPhotos
        } catch {
            return .failure(error.localizedDescription)
        }
    }

    private func makeFocusedMemory(for assetIdentifier: String, locationName: String?) -> Memory {
        Memory(
            id: UUID(),
            title: "A nearby moment",
            subtitle: "Latest photo taken near your current location.",
            dateText: "Recent photo",
            locationName: locationName,
            imageName: "",
            journalText: nil,
            isFavorite: false,
            tags: []
        )
    }

    private func refreshHomeCardState() {
        #if DEBUG
        homeCardState = qaDebugSettingsRepository.qaHomeCardState
        #else
        homeCardState = .normal
        #endif
    }

    deinit {
        loadTask?.cancel()
    }
}
