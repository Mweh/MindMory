import Combine
import SwiftUI
import UIKit

struct MemoriesHeaderCopy: Equatable {
    let title: String
    let subtitle: String
}

enum HomeViewState: Equatable {
    case loading
    case positive(Reminder, Memory?)
    case empty
    case permissionRequired
    case error(String)
}

enum MemoryCardSide: Equatable {
    case front
    case back
}

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var state: HomeViewState = .loading
    @Published private(set) var contextualState: ContextualMemoryState = .idle
    @Published private(set) var focusedMemory: Memory?
    @Published private(set) var contextualMemory: ContextualMemory?
    @Published private(set) var selectedAssetLocalIdentifier: String?
    @Published var cardSide: MemoryCardSide = .front
    @Published var captionText = ""
    @Published var homeCardState: HomeCardState = .normal
    @Published var isShowingSharePreview = false

    private let memories: [Memory]
    private let findContextualMemoryUseCase: FindContextualMemoryUseCase?
    private let getCurrentLocationUseCase: GetCurrentLocationUseCase?
    private let getCurrentEventUseCase: GetCurrentEventUseCase?
    private let contextualMemoryCacheRepository: ContextualMemoryCacheRepositoryProtocol?
    private let qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    private let cacheExpirationInterval: TimeInterval = 12 * 60 * 60
    private var contextualDiscoveryTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    var eventName: String {
        focusedMemory?.locationName ?? focusedMemory?.title ?? "this moment"
    }

    var focusedImageSource: MemoryImageSource {
        if let selectedAssetLocalIdentifier {
            return .assetLocalIdentifier(selectedAssetLocalIdentifier)
        }

        return focusedMemory?.imageSource ?? .placeholder
    }

    var headerCopy: MemoriesHeaderCopy {
        if case .loaded(let contextualMemory) = contextualState {
            if let event = contextualMemory.context.currentEvent {
                return MemoriesHeaderCopy(
                    title: "You’re in \(event.title).",
                    subtitle: "A memory that connects to this moment."
                )
            }

            return MemoriesHeaderCopy(
                title: "This place holds a memory.",
                subtitle: "A memory tied to your current location."
            )
        }

        if case .empty = contextualState {
            return MemoriesHeaderCopy(
                title: "No memory has surfaced yet.",
                subtitle: "MindMory is ready to match a moment from this location."
            )
        }

        if case .permissionRequired = contextualState {
            return MemoriesHeaderCopy(
                title: "Memories can meet you where you are.",
                subtitle: "Allow access so MindMory can surface the best local moment."
            )
        }

        return MemoriesHeaderCopy(
            title: "Finding a meaningful memory.",
            subtitle: "Searching for a memory tied to where you are now."
        )
    }

    var shouldShowContextualEmptyState: Bool {
        switch contextualState {
        case .empty, .error:
            return true
        default:
            return false
        }
    }

    var contextualErrorMessage: String? {
        if case let .error(message) = contextualState {
            return message
        }
        return nil
    }

    var locationBannerTitle: String {
        if let placemarkName = contextualMemory?.context.currentLocation?.placemarkName,
           !placemarkName.isEmpty {
            return placemarkName
        }

        if let eventLocation = contextualMemory?.context.currentEvent?.location,
           !eventLocation.isEmpty {
            return eventLocation
        }

        if let contextualLocationName = contextualMemory?.locationName,
           !contextualLocationName.isEmpty {
            return contextualLocationName
        }

        if let focusedLocationName = focusedMemory?.locationName,
           !focusedLocationName.isEmpty {
            return focusedLocationName
        }

        return "Memory matched to this location"
    }

    var locationBannerSubtitle: String {
        if let placemarkName = contextualMemory?.context.currentLocation?.placemarkName,
           !placemarkName.isEmpty {
            return "Matched to your current Apple Maps location."
        }

        if let eventLocation = contextualMemory?.context.currentEvent?.location,
           !eventLocation.isEmpty {
            return "Matched to your current event location."
        }

        if case .loaded = contextualState {
            return "A memory connected to where you are now."
        }

        return "A memory connected to where you are now."
    }

    init(
        memories: [Memory],
        findContextualMemoryUseCase: FindContextualMemoryUseCase? = nil,
        getCurrentLocationUseCase: GetCurrentLocationUseCase? = nil,
        getCurrentEventUseCase: GetCurrentEventUseCase? = nil,
        contextualMemoryCacheRepository: ContextualMemoryCacheRepositoryProtocol? = nil,
        qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    ) {
        self.memories = memories
        self.findContextualMemoryUseCase = findContextualMemoryUseCase
        self.getCurrentLocationUseCase = getCurrentLocationUseCase
        self.getCurrentEventUseCase = getCurrentEventUseCase
        self.contextualMemoryCacheRepository = contextualMemoryCacheRepository
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
        guard contextualDiscoveryTask == nil else { return }
        refreshHomeCardState()

        contextualDiscoveryTask = Task { [weak self] in
            await self?.loadContextualMemory()
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
        discoverContextualMemory()
    }

    func retryContextualDiscovery() {
        discoverContextualMemory()
    }

    private func loadContextualMemory() async {
        await MainActor.run {
            contextualState = .loading
        }

        guard let context = await currentContext() else {
            await MainActor.run {
                contextualState = .empty(.noContext)
                contextualDiscoveryTask = nil
            }
            return
        }

        if let cache = contextualMemoryCacheRepository?.load(), isCache(cache, validFor: context) {
            await MainActor.run {
                applyCachedMemory(cache, context: context)
                contextualDiscoveryTask = nil
            }
            return
        }
        let result = await findContextualMemoryUseCase?.execute(now: context.now) ?? .empty(.noContext)
        await MainActor.run {
            applyContextualMemoryState(result)
            contextualDiscoveryTask = nil
        }
    }

    private func currentContext(now: Date = Date()) async -> ContextualMemoryContext? {
        do {
            async let currentLocation = getCurrentLocationUseCase?.execute()
            async let currentEvent = getCurrentEventUseCase?.execute(at: now)
            let context = try await ContextualMemoryContext(
                now: now,
                currentLocation: currentLocation ?? nil,
                currentEvent: currentEvent ?? nil
            )
            return context.hasSignal ? context : nil
        } catch {
            return nil
        }
    }

    private func isCache(_ cache: ContextualMemoryCache, validFor context: ContextualMemoryContext, now: Date = Date()) -> Bool {
        guard now.timeIntervalSince(cache.discoveredAt) < cacheExpirationInterval else { return false }
        guard isEventCache(cache, validFor: context.currentEvent) else { return false }
        return isLocationCache(cache, validFor: context.currentLocation)
    }

    private func isEventCache(_ cache: ContextualMemoryCache, validFor event: CurrentEventContext?) -> Bool {
        cache.eventIdentifier == event?.id
    }

    private func isLocationCache(_ cache: ContextualMemoryCache, validFor location: CurrentLocationContext?) -> Bool {
        guard let cachedLatitude = cache.latitude,
              let cachedLongitude = cache.longitude,
              let location else {
            return cache.latitude == nil && cache.longitude == nil && location == nil
        }

        if let cachedKey = cache.locationKey,
           let currentKey = location.cacheKey,
           !cachedKey.isEmpty,
           !currentKey.isEmpty,
           cachedKey != currentKey {
            return false
        }

        return location.distance(from: ContextualMemoryLocation(latitude: cachedLatitude, longitude: cachedLongitude)) <= 1_000
    }

    private func applyCachedMemory(_ cache: ContextualMemoryCache, context: ContextualMemoryContext) {
        let cachedContextualMemory = cache.contextualMemory(context: context)
        contextualMemory = cachedContextualMemory
        focusedMemory = cache.memory
        selectedAssetLocalIdentifier = cache.assetLocalIdentifier
        captionText = cache.journalText ?? ""
        contextualState = .loaded(cachedContextualMemory)
        homeCardState = .normal
        state = .positive(
            Reminder(
                id: UUID(),
                title: cache.title,
                message: cache.subtitle,
                context: .none,
                imageName: nil
            ),
            focusedMemory
        )
    }

    func showContextualAsset(localIdentifier: String) {
        selectedAssetLocalIdentifier = localIdentifier
        let routedMemory = Memory(
            id: UUID(),
            title: "A memory is nearby",
            subtitle: "You’re near a place connected to this photo.",
            dateText: "Memory",
            locationName: nil,
            imageName: "",
            journalText: nil,
            isFavorite: false,
            tags: ["Nearby"]
        )
        let contextualMemory = ContextualMemory(
            id: routedMemory.id,
            title: routedMemory.title,
            subtitle: routedMemory.subtitle,
            dateText: routedMemory.dateText,
            locationName: routedMemory.locationName,
            assetLocalIdentifier: localIdentifier,
            journalText: routedMemory.journalText,
            tags: routedMemory.tags,
            context: ContextualMemoryContext(now: Date(), currentLocation: nil, currentEvent: nil),
            score: 0,
            distanceMeters: nil,
            notificationConfidenceScore: 0
        )
        focusedMemory = routedMemory
        cardSide = .front
        self.contextualMemory = contextualMemory
        captionText = ""
        contextualState = .loaded(contextualMemory)
        homeCardState = .normal
        state = .positive(
            Reminder(
                id: UUID(),
                title: routedMemory.title,
                message: routedMemory.subtitle,
                context: .none,
                imageName: nil
            ),
            routedMemory
        )
    }

    private func discoverContextualMemory() {
        contextualDiscoveryTask?.cancel()
        contextualState = .loading

        contextualDiscoveryTask = Task { [weak self] in
            let result = await self?.findContextualMemoryUseCase?.execute() ?? .empty(.noContext)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.applyContextualMemoryState(result)
                self?.contextualDiscoveryTask = nil
            }
        }
    }

    private func applyContextualMemoryState(_ newState: ContextualMemoryState) {
        contextualState = newState

        switch newState {
        case .loaded(let contextualMemory):
            self.contextualMemory = contextualMemory
            focusedMemory = contextualMemory.asMemory
            selectedAssetLocalIdentifier = contextualMemory.assetLocalIdentifier
            contextualMemoryCacheRepository?.save(contextualMemory.makeCache())
            captionText = contextualMemory.journalText ?? ""
            state = .positive(
                Reminder(
                    id: UUID(),
                    title: contextualMemory.title,
                    message: contextualMemory.subtitle,
                    context: .none,
                    imageName: nil
                ),
                focusedMemory
            )
        case .permissionRequired(.photoLibrary):
            contextualMemory = nil
            selectedAssetLocalIdentifier = nil
        case .empty, .error:
            contextualMemory = nil
            selectedAssetLocalIdentifier = nil
        case .idle, .loading, .permissionRequired:
            break
        }

    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url)
    }

    private func refreshHomeCardState() {
        #if DEBUG
        homeCardState = qaDebugSettingsRepository.qaHomeCardState
        #else
        homeCardState = .normal
        #endif
    }


    deinit {
        contextualDiscoveryTask?.cancel()
    }
}
