import SwiftUI
import Combine

enum OnboardingViewState: Equatable { case showingPage(Int), permissionEducation, completed }

final class OnboardingViewModel: ObservableObject {
    @Published private(set) var state: OnboardingViewState = .showingPage(0)
    let pages: [OnboardingPage]
    var currentIndex: Int { if case let .showingPage(index)=state { return index }; return pages.count-1 }
    init(pages: [OnboardingPage]) { self.pages = pages }
    func pageChanged(to index: Int) { state = .showingPage(index) }
    func continueTapped() { currentIndex >= pages.count - 1 ? (state = .completed) : (state = .showingPage(currentIndex + 1)) }
    func maybeLaterTapped() { state = .completed }
    func permissionsEnabled() { state = .completed }
}
