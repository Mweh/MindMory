import SwiftUI
import Combine

enum OnboardingViewState: Equatable {
    case showingPage(Int)
    case permissionEducation
    case completed
}

final class OnboardingViewModel: ObservableObject {

    @Published private(set) var state: OnboardingViewState = .showingPage(0)

    let pages: [OnboardingPage]

    var currentIndex: Int {
        guard case let .showingPage(index) = state else {
            return pages.count - 1
        }

        return index
    }

    init(pages: [OnboardingPage]) {
        self.pages = pages
    }

    func pageChanged(to index: Int) {
        state = .showingPage(index)
    }

    func continueTapped() {
        if currentIndex >= pages.count - 1 {
            state = .completed
        } else {
            state = .showingPage(currentIndex + 1)
        }
    }

    func maybeLaterTapped() {
        state = .completed
    }

    func permissionsEnabled() {
        state = .completed
    }
}
