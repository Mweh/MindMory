import Combine
import Foundation
import SwiftUI

@MainActor
final class QADebugToolsViewModel: ObservableObject {

    @Published var skipOnboarding: Bool {
        didSet { repository.hasCompletedOnboarding = skipOnboarding }
    }
    @Published var homeCardState: HomeCardState {
        didSet {
            repository.qaHomeCardState = homeCardState
            NotificationCenter.default.post(name: .qaDebugHomeCardStateDidChange, object: nil)
        }
    }
    @Published var statusMessage: String?

    private let repository: QADebugSettingsRepositoryProtocol

    init(
        repository: QADebugSettingsRepositoryProtocol
    ) {
        self.repository = repository
        self.skipOnboarding = repository.hasCompletedOnboarding
        self.homeCardState = repository.qaHomeCardState
    }

    func resetOnboarding() {
        skipOnboarding = false
        repository.hasCompletedOnboarding = false
        statusMessage = "Onboarding will appear again after relaunch."
    }
}

extension Notification.Name {
    static let qaDebugHomeCardStateDidChange = Notification.Name("qaDebugHomeCardStateDidChange")
}
