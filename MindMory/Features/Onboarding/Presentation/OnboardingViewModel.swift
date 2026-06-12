import SwiftUI
import Combine

enum OnboardingViewState: Equatable {
    case showingPage(Int)
    case completed
}

enum OnboardingAlert: Identifiable, Equatable {
    case permissionDenied(OnboardingPermission)

    var id: String {
        switch self {
        case let .permissionDenied(permission):
            return "permission-denied-\(permission.rawValue)"
        }
    }
}

@MainActor
final class OnboardingViewModel: ObservableObject {

    @Published private(set) var state: OnboardingViewState = .showingPage(0)
    @Published private(set) var isProcessingPermission = false
    @Published var activeAlert: OnboardingAlert?

    let pages: [OnboardingPage]
    private let requestLocationPermissionUseCase: RequestLocationPermissionUseCase
    private let requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase
    private let requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase
    private var pendingAdvanceIndex: Int?

    var currentIndex: Int {
        if case let .showingPage(index) = state {
            return index
        }

        return pages.count - 1
    }

    init(
        pages: [OnboardingPage],
        requestLocationPermissionUseCase: RequestLocationPermissionUseCase,
        requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase,
        requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase
    ) {
        self.pages = pages
        self.requestLocationPermissionUseCase = requestLocationPermissionUseCase
        self.requestCalendarPermissionUseCase = requestCalendarPermissionUseCase
        self.requestNotificationPermissionUseCase = requestNotificationPermissionUseCase
    }

    func pageChanged(to index: Int) {
        guard !isProcessingPermission else {
            return
        }
        
        if index > currentIndex {
            Task {
                await continueTapped()
            }
        } else {
            state = .showingPage(index)
        }
        
    }

    func continueTapped() async {
        guard !isProcessingPermission else {
            return
        }

        let page = pages[currentIndex]

        if let permission = page.permission {
            isProcessingPermission = true
            let status = await requestPermission(permission)
            isProcessingPermission = false

            if status == .denied {
                pendingAdvanceIndex = currentIndex
                activeAlert = .permissionDenied(permission)
            } else {
                advance(from: currentIndex)
            }
        } else {
            advance(from: currentIndex)
        }
    }

    func continueAfterPermissionAlert() {
        guard let pageIndex = pendingAdvanceIndex else {
            return
        }

        pendingAdvanceIndex = nil
        activeAlert = nil
        advance(from: pageIndex)
    }

    func dismissPermissionAlert() {
        pendingAdvanceIndex = nil
        activeAlert = nil
    }

    private func advance(from pageIndex: Int) {
        if pageIndex >= pages.count - 1 {
            state = .completed
        } else {
            state = .showingPage(pageIndex + 1)
        }
    }

    private func requestPermission(_ permission: OnboardingPermission) async -> PermissionStatus {
        switch permission {
        case .location:
            return await requestLocationPermissionUseCase.execute()
        case .calendar:
            return await requestCalendarPermissionUseCase.execute()
        case .notification:
            return await requestNotificationPermissionUseCase.execute()
        }
    }
}
