import SwiftUI
import Combine

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

final class HomeViewModel: ObservableObject {

    @Published private(set) var state: HomeViewState = .loading
    @Published private(set) var focusedMemory: Memory?
    @Published private(set) var statCards: [HomeStatCardModel] = []
    @Published var selectedStat: SelectedStatCard? = nil
    @Published var cardSide: MemoryCardSide = .front
    @Published var captionText = ""
    @Published var isShowingSharePreview = false
    @Published private(set) var debugHomeCardImageURL: URL?

    private let memories: [Memory]
    private let qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    private let debugImageStorageService: DebugImageStorageService
    private var cancellables = Set<AnyCancellable>()

    var eventName: String {
        focusedMemory?.locationName ?? focusedMemory?.title ?? "this moment"
    }

    init(
        memories: [Memory],
        qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol = QADebugSettingsRepository(),
        debugImageStorageService: DebugImageStorageService = DebugImageStorageService()
    ) {
        self.memories = memories
        self.qaDebugSettingsRepository = qaDebugSettingsRepository
        self.debugImageStorageService = debugImageStorageService
        NotificationCenter.default.publisher(for: .qaDebugHomeCardImageDidChange)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refreshDebugHomeCardImage()
                }
            }
            .store(in: &cancellables)
    }

    func load() {
        focusedMemory = memories.first(where: \.isFavorite) ?? memories.first
        captionText = focusedMemory?.journalText ?? ""
        statCards = makeStatCards()
        refreshDebugHomeCardImage()
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
    }

    func selectStat(_ stat: SelectedStatCard) {
        withAnimation(.easeInOut(duration: 0.35)) {
            selectedStat = selectedStat == stat ? nil : stat
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

    private func refreshDebugHomeCardImage() {
        #if DEBUG
        debugHomeCardImageURL = debugImageStorageService.imageURL(
            path: qaDebugSettingsRepository.debugHomeCardImagePath
        )
        #else
        debugHomeCardImageURL = nil
        #endif
    }

    private func makeStatCards() -> [HomeStatCardModel] {
        [
            HomeStatCardModel(stat: .captured, title: "Captured", primaryValue: "5", secondaryValue: "Moments", monthlyDetail: "12 This Month", yearlyDetail: "20 This Year"),
            HomeStatCardModel(stat: .visited, title: "Visited", primaryValue: "2 times", secondaryValue: eventName, monthlyDetail: "4 This Month", yearlyDetail: "9 This Year"),
            HomeStatCardModel(stat: .reminder, title: "Reminder", primaryValue: "5", secondaryValue: "Responded", monthlyDetail: "8 This Month", yearlyDetail: "18 This Year")
        ]
    }
}
