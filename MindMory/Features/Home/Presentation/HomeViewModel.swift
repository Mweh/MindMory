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
    case success(String)
    case noPhotos
    case permissionRequired(HomePermissionKind)
    case permissionDenied(HomePermissionKind)
    case failure(String)
}

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var photoState: HomePhotoState = .idle
    @Published private(set) var focusedMemory: Memory?
    @Published private(set) var selectedAssetLocalIdentifier: String?
    @Published private(set) var recentPhotoAssetIdentifiers: [String] = []
    @Published private(set) var peoplePhotoAssetIdentifiers: [String] = []
    @Published private(set) var qaDebugPlaceholderCount: Int = 0
    @Published var cardSide: MemoryCardSide = .front
    @Published var captionText = ""
    @Published var isShowingSharePreview = false

    private let fetchLocationPhotoListsUseCase: FetchLocationPhotoListsUseCase?
    private let getCurrentLocationUseCase: GetCurrentLocationUseCase?
    private let qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol?
    private var loadTask: Task<Void, Never>?
    private var qaDebugObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()

    var focusedImageSource: MemoryImageSource {
        if qaDebugModeEnabled {
            return .placeholder
        }

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
        qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol? = nil
    ) {
        self.fetchLocationPhotoListsUseCase = fetchLocationPhotoListsUseCase
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
        self.qaDebugSettingsRepository = qaDebugSettingsRepository

        qaDebugObserver = NotificationCenter.default.addObserver(
            forName: .qaDebugSettingsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshState()
        }
    }

    func load() {
        guard loadTask == nil else { return }
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
        Task { @MainActor in
            photoState = .idle
            focusedMemory = nil
            selectedAssetLocalIdentifier = nil
            recentPhotoAssetIdentifiers = []
            peoplePhotoAssetIdentifiers = []
        }
        loadTask = Task { [weak self] in
            await self?.evaluateCurrentState()
        }
    }

    private var qaDebugModeEnabled: Bool {
        qaDebugSettingsRepository?.qaDebugModeEnabled == true
    }

    private var qaDebugFavoriteState: QADebugHomeState {
        if let locationPermissionState = qaDebugSettingsRepository?.qaLocationPermissionState,
           locationPermissionState != .none {
            if locationPermissionState == .permissionGrantedLocation {
                // A granted permission override should not block home debug states.
            } else {
                return locationPermissionState
            }
        }

        if let photoLibraryPermissionState = qaDebugSettingsRepository?.qaPhotoLibraryPermissionState,
           photoLibraryPermissionState != .none {
            if photoLibraryPermissionState == .permissionGrantedPhotoLibrary {
                // A granted permission override should not block home debug states.
            } else {
                return photoLibraryPermissionState
            }
        }

        let state = qaDebugSettingsRepository?.qaHomeState ?? .none
        switch state {
        case .loadedFavorite, .empty, .error, .permissionRequiredLocation, .permissionRequiredPhotoLibrary, .permissionDeniedLocation, .permissionDeniedPhotoLibrary, .permissionGrantedLocation, .permissionGrantedPhotoLibrary:
            return state
        default:
            return .none
        }
    }

    private var qaDebugRecentState: QADebugHomeState {
        let state = qaDebugSettingsRepository?.qaRecentState ?? .none
        switch state {
        case .loadedOne, .loadedTwo, .loadedThree, .empty, .error:
            return state
        default:
            return .none
        }
    }

    private var qaDebugPermissionState: HomePhotoState? {
        if let locationPermissionState = qaDebugSettingsRepository?.qaLocationPermissionState,
           locationPermissionState.isBlocking {
            switch locationPermissionState {
            case .permissionRequiredLocation:
                return .permissionRequired(.location)
            case .permissionDeniedLocation:
                return .permissionDenied(.location)
            default:
                break
            }
        }

        if let photoLibraryPermissionState = qaDebugSettingsRepository?.qaPhotoLibraryPermissionState,
           photoLibraryPermissionState.isBlocking {
            switch photoLibraryPermissionState {
            case .permissionRequiredPhotoLibrary:
                return .permissionRequired(.photoLibrary)
            case .permissionDeniedPhotoLibrary:
                return .permissionDenied(.photoLibrary)
            default:
                break
            }
        }

        return nil
    }

    private func evaluateCurrentState() async {
        if Task.isCancelled { return }

        if qaDebugModeEnabled, let permissionState = qaDebugPermissionState {
            await updateState(permissionState, withMemory: nil, debugPlaceholderCount: debugPlaceholderCount(for: qaDebugRecentState))
            return
        }

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

        let loadResult = await loadPhotoAssets(near: currentLocation)

        if Task.isCancelled { return }

        let recentQAState = qaDebugModeEnabled ? qaDebugRecentState : .none
        let favoriteQAState = qaDebugModeEnabled ? qaDebugFavoriteState : .none

        switch loadResult {
        case .success(let assetLocalIdentifier):
            let memory = makeFocusedMemory(for: assetLocalIdentifier, locationName: currentLocation.placemarkName)
            if favoriteQAState != .none {
                await updateStateFromQAFavorite(favoriteQAState, recentQAState)
            } else {
                await updateState(.loaded, withMemory: memory, assetIdentifier: assetLocalIdentifier,
                                  debugPlaceholderCount: debugPlaceholderCount(for: recentQAState))
            }
        case .noPhotos:
            if favoriteQAState != .none {
                await updateStateFromQAFavorite(favoriteQAState, recentQAState)
            } else {
                await updateState(
                    .empty(
                        title: "No nearby photos found.",
                        subtitle: "Try moving closer to a place where you took a photo."
                    ),
                    withMemory: nil,
                    debugPlaceholderCount: debugPlaceholderCount(for: recentQAState)
                )
            }
        case .permissionRequired(let permissionKind):
            await updateState(.permissionRequired(permissionKind), withMemory: nil,
                              debugPlaceholderCount: debugPlaceholderCount(for: recentQAState))
        case .permissionDenied(let permissionKind):
            await updateState(.permissionDenied(permissionKind), withMemory: nil,
                              debugPlaceholderCount: debugPlaceholderCount(for: recentQAState))
        case .failure(let message):
            await updateState(.error(message), withMemory: nil,
                              debugPlaceholderCount: debugPlaceholderCount(for: recentQAState))
        }
    }

    private func requestMissingPermission() async {
        if Task.isCancelled { return }

        guard let locationUseCase = getCurrentLocationUseCase,
              let photoUseCase = fetchLocationPhotoListsUseCase else {
            await updateState(.error("Unable to request access at this time."), withMemory: nil)
            return
        }

        let locationStatus = await locationUseCase.authorizationStatus()
        let photoStatus = await photoUseCase.authorizationStatus()
        let targetPermission = permissionToRequest(locationStatus: locationStatus, photoStatus: photoStatus)

        guard let permission = targetPermission else {
            await refreshState()
            return
        }

        let permissionStatus: PermissionStatus
        switch permission {
        case .location:
            permissionStatus = await locationUseCase.requestAuthorization()
        case .photoLibrary:
            permissionStatus = await photoUseCase.requestAuthorization()
        }

        if Task.isCancelled { return }

        await MainActor.run {
            photoState = permissionStatus == .granted
                ? .loading
                : .permissionDenied(permission)
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
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                return nil
            }

            let result = await group.next()
            group.cancelAll()
            return result ?? nil
        }
    }

    private func permissionState(for locationStatus: PermissionStatus, photoStatus: PermissionStatus) -> HomePhotoState? {
        if locationStatus == .denied {
            return .permissionDenied(.location)
        }

        if photoStatus == .denied {
            return .permissionDenied(.photoLibrary)
        }

        if locationStatus == .notDetermined {
            return .permissionRequired(.location)
        }

        if photoStatus == .notDetermined {
            return .permissionRequired(.photoLibrary)
        }

        return nil
    }

    private func permissionToRequest(locationStatus: PermissionStatus, photoStatus: PermissionStatus) -> HomePermissionKind? {
        if locationStatus == .notDetermined {
            return .location
        }

        if photoStatus == .notDetermined {
            return .photoLibrary
        }

        if locationStatus == .denied {
            return .location
        }

        if photoStatus == .denied {
            return .photoLibrary
        }

        return nil
    }

    private func updateState(_ state: HomePhotoState, withMemory memory: Memory?, assetIdentifier: String? = nil, debugPlaceholderCount: Int = 0) async {
        await MainActor.run {
            photoState = state
            focusedMemory = memory
            selectedAssetLocalIdentifier = assetIdentifier
            qaDebugPlaceholderCount = debugPlaceholderCount

            if case .loaded = state {
                if debugPlaceholderCount > 0 {
                    recentPhotoAssetIdentifiers = []
                    peoplePhotoAssetIdentifiers = []
                }
            } else {
                recentPhotoAssetIdentifiers = []
                peoplePhotoAssetIdentifiers = []
            }
            loadTask = nil
        }
    }

    private func updateStateFromQAFavorite(_ favoriteState: QADebugHomeState, _ recentState: QADebugHomeState) async {
        let configuration = debugQAStateConfiguration(for: favoriteState)
        await updateState(
            configuration.photoState,
            withMemory: configuration.memory,
            assetIdentifier: configuration.assetIdentifier,
            debugPlaceholderCount: debugPlaceholderCount(for: recentState)
        )
    }

    private func debugPlaceholderCount(for state: QADebugHomeState) -> Int {
        switch state {
        case .loadedOne:
            return 1
        case .loadedTwo:
            return 2
        case .loadedThree:
            return 3
        default:
            return 0
        }
    }

    private func loadPhotoAssets(near location: CurrentLocationContext) async -> HomePhotoLoadResult {
        guard let useCase = fetchLocationPhotoListsUseCase else {
            return .failure("Location photo feature is unavailable.")
        }

        let photoStatus = await useCase.authorizationStatus()
        switch photoStatus {
        case .granted:
            break
        case .notDetermined:
            return .permissionRequired(.photoLibrary)
        case .denied:
            return .permissionDenied(.photoLibrary)
        }

        do {
            async let favoriteAsset = useCase.fetchFavoritePhotoAsset(near: location)
            async let recentAssets = useCase.fetchRecentPhotoAssets(near: location)
            async let peopleAssets = useCase.fetchRecentPhotoAssetsWithPeople(near: location)

            let favoriteIdentifier = try await favoriteAsset
            let recentIdentifiers = try await recentAssets
            let peopleIdentifiers = try await peopleAssets

            await MainActor.run {
                self.recentPhotoAssetIdentifiers = recentIdentifiers
                self.peoplePhotoAssetIdentifiers = peopleIdentifiers
            }

            if let favoriteIdentifier = favoriteIdentifier {
                return .success(favoriteIdentifier)
            }

            if let recentIdentifier = recentIdentifiers.first {
                return .success(recentIdentifier)
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

    private func makeDebugMemory(isFavorite: Bool = false) -> Memory {
        Memory(
            id: UUID(),
            title: isFavorite ? "Favorite nearby moment" : "Nearby memory",
            subtitle: isFavorite ? "This is a QA favorite preview." : "This is a QA debug preview.",
            dateText: "Recent photo",
            locationName: "QA debug location",
            imageName: "",
            journalText: nil,
            isFavorite: isFavorite,
            tags: []
        )
    }

    private func debugQAStateConfiguration(for state: QADebugHomeState) -> (photoState: HomePhotoState, memory: Memory?, assetIdentifier: String?, debugPlaceholderCount: Int) {
        switch state {
        case .none:
            return (.idle, nil, nil, 0)
        case .loadedOne:
            return (.loaded, makeDebugMemory(), nil, 1)
        case .loadedTwo:
            return (.loaded, makeDebugMemory(), nil, 2)
        case .loadedThree:
            return (.loaded, makeDebugMemory(), nil, 3)
        case .loadedFavorite:
            return (.loaded, makeDebugMemory(isFavorite: true), nil, 0)
        case .empty:
            return (
                .empty(
                    title: "No nearby photos found.",
                    subtitle: "QA debug empty state generated."
                ),
                nil,
                nil,
                0
            )
        case .error:
            return (.error("QA debug error state."), nil, nil, 0)
        case .permissionRequiredLocation:
            return (.permissionRequired(.location), nil, nil, 0)
        case .permissionRequiredPhotoLibrary:
            return (.permissionRequired(.photoLibrary), nil, nil, 0)
        case .permissionDeniedLocation:
            return (.permissionDenied(.location), nil, nil, 0)
        case .permissionDeniedPhotoLibrary:
            return (.permissionDenied(.photoLibrary), nil, nil, 0)
        case .permissionGrantedLocation,
             .permissionGrantedPhotoLibrary:
            return (.idle, nil, nil, 0)
        }
    }

    deinit {
        loadTask?.cancel()
        if let qaDebugObserver {
            NotificationCenter.default.removeObserver(qaDebugObserver)
        }
    }
}
