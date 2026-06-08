import SwiftUI
import Combine

enum HomeViewState: Equatable {
    case loading
    case positive(Reminder, Memory?)
    case empty
    case permissionRequired
    case error(String)
}

enum SelectedHomeStat: CaseIterable, Equatable {
    case captured
    case visited
    case reminder
}

enum MemoryCardSide: Equatable {
    case front
    case back
}

struct HomeStatCardModel: Identifiable, Equatable {
    let stat: SelectedHomeStat
    let title: String
    let primaryValue: String
    let secondaryValue: String
    let monthlyDetail: String
    let yearlyDetail: String

    var id: SelectedHomeStat { stat }
}

final class HomeViewModel: ObservableObject {

    @Published private(set) var state: HomeViewState = .loading
    @Published private(set) var focusedMemory: Memory?
    @Published private(set) var statCards: [HomeStatCardModel] = []
    @Published var selectedStat: SelectedHomeStat = .captured
    @Published var cardSide: MemoryCardSide = .front
    @Published var captionText = ""
    @Published var isShowingSharePreview = false

    private let memories: [Memory]

    var eventName: String {
        focusedMemory?.locationName ?? focusedMemory?.title ?? "this moment"
    }

    init(memories: [Memory]) {
        self.memories = memories
    }

    func load() {
        focusedMemory = memories.first(where: \.isFavorite) ?? memories.first
        captionText = focusedMemory?.journalText ?? ""
        statCards = makeStatCards()
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

    func selectStat(_ stat: SelectedHomeStat) {
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

    private func makeStatCards() -> [HomeStatCardModel] {
        [
            HomeStatCardModel(stat: .captured, title: "Captured", primaryValue: "5", secondaryValue: "Moments", monthlyDetail: "12 This Month", yearlyDetail: "20 This Year"),
            HomeStatCardModel(stat: .visited, title: "Visited", primaryValue: "2 times", secondaryValue: eventName, monthlyDetail: "4 This Month", yearlyDetail: "9 This Year"),
            HomeStatCardModel(stat: .reminder, title: "Reminder", primaryValue: "5", secondaryValue: "Responded", monthlyDetail: "8 This Month", yearlyDetail: "18 This Year")
        ]
    }
}
