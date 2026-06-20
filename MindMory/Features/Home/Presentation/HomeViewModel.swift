import Combine
import SwiftUI
import UIKit

struct MemoriesHeaderCopy: Equatable {
    let title: String
    let subtitle: String
}

enum HomePhotoState: Equatable {
    case idle
    case loading
    case loaded
    case empty(title: String, subtitle: String)
    case permissionRequired(HomePermissionKind)
    case permissionDenied(HomePermissionKind)
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
    case success(String?)
    case noPhotos
    case permissionRequired
    case failure(String)
}

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var photoState: HomePhotoState = .idle
    @Published private(set) var focusedMemory: Memory?
    @Published private(set) var selectedAssetLocalIdentifier: String?
    @Published private(set) var peoplePhotoAssetIdentifiers: [String] = []
    @Published private(set) var recentPhotoAssetIdentifiers: [String] = []
    @Published var cardSide: MemoryCardSide = .front
    @Published var captionText = ""
    @Published var homeCardState: HomeCardState = .normal
    @Published var isShowingSharePreview = false

    private let fetchLocationPhotoListsUseCase: FetchLocationPhotoListsUseCase?
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
        case .permissionDenied(.photoLibrary):
            return MemoriesHeaderCopy(
                title: "Photo access denied",
                subtitle: "Open Settings to grant photo access and continue seeing nearby memories."
            )
        case .permissionDenied(.location):
            return MemoriesHeaderCopy(
                title: "Location access denied",
                subtitle: "Open Settings to grant location access so MindMory can find nearby memories."
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
        case .idle:
            return MemoriesHeaderCopy(
                title: "Checking your access permissions.",
                subtitle: "Verifying location and photo library access before showing nearby memories."
            )
        }
    }

    init(
        fetchLocationPhotoListsUseCase: FetchLocationPhotoListsUseCase? = nil,
        getCurrentLocationUseCase: GetCurrentLocationUseCase? = nil,
        qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    ) {
        self.fetchLocationPhotoListsUseCase = fetchLocationPhotoListsUseCase
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
        refreshState()
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
            await self?.requestMissingPermission()
        }
    }

    func retryContextualDiscovery() {
        refreshState()
    }

    private func refreshState() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.evaluateCurrentState()
        }
    }

    private func evaluateCurrentState() async {
        if Task.isCancelled { return }

        guard let locationUseCase = getCurrentLocationUseCase else {
            await updateState(.error("Location services are unavailable."), withMemory: nil)
            return
        }

        guard let photoUseCase = fetchLocationPhotoListsUseCase else {
            await updateState(.error("Photo library access is unavailable."), withMemory: nil)
            return
        }

        let locationStatus = await locationUseCase.authorizationStatus()
        let photoStatus = await photoUseCase.authorizationStatus()

        if Task.isCancelled { return }

        if let permissionState = permissionState(for: locationStatus, photoStatus: photoStatus) {
            await updateState(permissionState, withMemory: nil)
            return
        }

        await updateState(.loading, withMemory: nil)

        guard let currentLocation = await fetchCurrentLocation(using: locationUseCase) else {
            await updateState(
                .error("Unable to determine your current location. Please check your device settings and try again."),
                withMemory: nil
            )
            return
        }

        let loadResult = await loadPhotoAsset(near: currentLocation)

        if Task.isCancelled { return }

        switch loadResult {
        case .success(let assetLocalIdentifier):
            if let assetLocalIdentifier {
                let memory = makeFocusedMemory(for: assetLocalIdentifier, locationName: currentLocation.placemarkName)
                await updateState(.loaded, withMemory: memory, assetIdentifier: assetLocalIdentifier)
            } else {
                await updateState(.loaded, withMemory: nil, assetIdentifier: nil)
            }
        case .noPhotos:
            await updateState(
                .empty(
                    title: "No nearby photo found.",
                    subtitle: "Try moving closer to a place where you took a photo."
                ),
                withMemory: nil
            )
        case .permissionRequired:
            await updateState(.permissionDenied(.photoLibrary), withMemory: nil)
        case .failure(let message):
            await updateState(.error(message), withMemory: nil)
        }
    }

    private func requestMissingPermission() async {
        if Task.isCancelled { return }

        let targetPermission: HomePermissionKind = {
            switch photoState {
            case .permissionRequired(let kind), .permissionDenied(let kind):
                return kind
            default:
                return .location
            }
        }()

        let permissionStatus: PermissionStatus
        switch targetPermission {
        case .location:
            permissionStatus = await getCurrentLocationUseCase?.requestAuthorization() ?? .denied
        case .photoLibrary:
            permissionStatus = await fetchLocationPhotoListsUseCase?.requestAuthorization() ?? .denied
        }

        if Task.isCancelled { return }

        await MainActor.run {
            photoState = permissionStatus == .granted
                ? .loading
                : .permissionDenied(targetPermission)
        }

        if permissionStatus == .granted {
            await evaluateCurrentState()
        } else {
            await MainActor.run { loadTask = nil }
        }
    }

    private func fetchCurrentLocation(using locationUseCase: GetCurrentLocationUseCase) async -> CurrentLocationContext? {
        await withTaskGroup(of: CurrentLocationContext?.self) { group in
            group.addTask {
                try? await locationUseCase.execute()
            }

            group.addTask {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                return nil
            }

            let result = await group.next()
            group.cancelAll()
            return result ?? nil
        }
    }

    private func permissionState(for locationStatus: PermissionStatus, photoStatus: PermissionStatus) -> HomePhotoState? {
        if photoStatus == .denied {
            return .permissionDenied(.photoLibrary)
        }

        if locationStatus == .denied {
            return .permissionDenied(.location)
        }

        if locationStatus == .notDetermined {
            return .permissionRequired(.location)
        }

        if photoStatus == .notDetermined {
            return .permissionRequired(.photoLibrary)
        }

        return nil
    }

    private func updateState(_ state: HomePhotoState, withMemory memory: Memory?, assetIdentifier: String? = nil) async {
        await MainActor.run {
            photoState = state
            focusedMemory = memory
            selectedAssetLocalIdentifier = assetIdentifier
            if case .loaded = state {
                // preserve loaded photo lists until a non-loaded state replaces them
            } else {
                peoplePhotoAssetIdentifiers = []
                recentPhotoAssetIdentifiers = []
            }
            loadTask = nil
        }
    }

    private func loadPhotoAsset(near location: CurrentLocationContext) async -> HomePhotoLoadResult {
        guard let useCase = fetchLocationPhotoListsUseCase else {
            return .failure("Location photo feature is unavailable.")
        }

        let photoStatus = await useCase.authorizationStatus()
        switch photoStatus {
        case .granted:
            break
        case .notDetermined, .denied:
            return .permissionRequired
        }

        do {
            async let favoriteAsset = useCase.fetchFavoritePhotoAsset(near: location)
            async let peopleAssets = useCase.fetchPeoplePhotoAssets(near: location)
            async let recentAssets = useCase.fetchRecentPhotoAssets(near: location)

            let favoriteIdentifier = try await favoriteAsset
            let peopleIdentifiers = try await peopleAssets
            let recentIdentifiers = try await recentAssets

            await MainActor.run {
                self.peoplePhotoAssetIdentifiers = peopleIdentifiers
                self.recentPhotoAssetIdentifiers = recentIdentifiers
            }

            if favoriteIdentifier != nil || !peopleIdentifiers.isEmpty || !recentIdentifiers.isEmpty {
                return .success(favoriteIdentifier)
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
