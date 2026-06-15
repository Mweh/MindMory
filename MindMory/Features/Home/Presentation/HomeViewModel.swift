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

enum SelectedStatCard: CaseIterable, Equatable {
    case captured
    case visited
    case reminder
}

enum MemoryCardSide: Equatable {
    case front
    case back
}

struct HomeStatCardModel: Identifiable, Equatable {
    let stat: SelectedStatCard
    let title: String
    let primaryValue: String
    let secondaryValue: String
    let monthlyDetail: String
    let yearlyDetail: String

    var id: SelectedStatCard { stat }
}

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var state: HomeViewState = .loading
    @Published private(set) var contextualState: ContextualMemoryState = .idle
    @Published private(set) var focusedMemory: Memory?
    @Published private(set) var contextualMemory: ContextualMemory?
    @Published private(set) var selectedAssetLocalIdentifier: String?
    @Published private(set) var statCards: [HomeStatCardModel] = []
    @Published var selectedStat: SelectedStatCard? = nil
    @Published var cardSide: MemoryCardSide = .front
    @Published var captionText = ""
    @Published var homeCardState: HomeCardState = .normal
    @Published var isShowingSharePreview = false

    private let memories: [Memory]
    private let findContextualMemoryUseCase: FindContextualMemoryUseCase?
    private let qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
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
                    subtitle: "Here’s a memory connected to this moment."
                )
            }

            return MemoriesHeaderCopy(
                title: "You’ve been here before.",
                subtitle: "A memory from around this place."
            )
        }

        if case .empty = contextualState {
            return MemoriesHeaderCopy(
                title: "This might be your first memory here.",
                subtitle: "We’ll help you keep this moment when it becomes worth remembering."
            )
        }

        if case .permissionRequired = contextualState {
            return MemoriesHeaderCopy(
                title: "Memories can meet you where you are.",
                subtitle: "Allow access when you’re ready to rediscover nearby moments."
            )
        }

        return MemoriesHeaderCopy(
            title: "You’re in the middle of \(eventName).",
            subtitle: "Finding a memory connected to this moment."
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

    init(
        memories: [Memory],
        findContextualMemoryUseCase: FindContextualMemoryUseCase? = nil,
        qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    ) {
        self.memories = memories
        self.findContextualMemoryUseCase = findContextualMemoryUseCase
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
        focusedMemory = memories.first(where: \.isFavorite) ?? memories.first
        contextualMemory = nil
        selectedAssetLocalIdentifier = nil
        captionText = focusedMemory?.journalText ?? ""
        statCards = makeStatCards()
        refreshHomeCardState()
        state = focusedMemory == nil ? .empty : .positive(
            Reminder(
                id: UUID(),
                title: "Capture it before it’s gone.",
                message: "You’re in the middle of \(eventName).",
                context: .none,
                imageName: focusedMemory?.imageName
            ),
            focusedMemory
        )
        discoverContextualMemory()
    }

    func selectStat(_ stat: SelectedStatCard) {
        selectedStat = stat
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

    func didTapAllowPhotoAccess() {
        if case .permissionRequired(.photoLibrary) = contextualState {
            discoverContextualMemory()
        } else {
            openAppSettings()
        }
    }

    func retryContextualDiscovery() {
        discoverContextualMemory()
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
        guard let findContextualMemoryUseCase else { return }
        contextualDiscoveryTask?.cancel()
        contextualState = .loading

        contextualDiscoveryTask = Task { [weak self] in
            let result = await findContextualMemoryUseCase.execute()
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.applyContextualMemoryState(result)
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

        statCards = makeStatCards()
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

    private func makeStatCards() -> [HomeStatCardModel] {
        [
            HomeStatCardModel(stat: .captured, title: "Captured", primaryValue: "5", secondaryValue: "Moments", monthlyDetail: "12 This Month", yearlyDetail: "20 This Year"),
            HomeStatCardModel(stat: .visited, title: "Visited", primaryValue: "2 times", secondaryValue: eventName, monthlyDetail: "4 This Month", yearlyDetail: "9 This Year"),
            HomeStatCardModel(stat: .reminder, title: "Reminder", primaryValue: "5", secondaryValue: "Responded", monthlyDetail: "8 This Month", yearlyDetail: "18 This Year")
        ]
    }

    deinit {
        contextualDiscoveryTask?.cancel()
    }
}
