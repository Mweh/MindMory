import Combine
import Foundation
import SwiftUI

@MainActor
final class QADebugToolsViewModel: ObservableObject {

    private static let defaultHomeState: QADebugHomeState = .loadedFavorite
    private static let defaultRecentState: QADebugHomeState = .loadedOne
    private static let defaultLocationPermissionState: QADebugHomeState = .permissionGrantedLocation
    private static let defaultPhotoLibraryPermissionState: QADebugHomeState = .permissionGrantedPhotoLibrary

    @Published var skipOnboarding: Bool {
        didSet { repository.hasCompletedOnboarding = skipOnboarding }
    }
    @Published var selectedHomeState: QADebugHomeState {
        didSet {
            guard !isSynchronizingState else { return }
            synchronizeHomeStateChange()
        }
    }
    @Published var selectedRecentState: QADebugHomeState {
        didSet {
            guard !isSynchronizingState else { return }
            synchronizeRecentStateChange()
        }
    }
    @Published var selectedLocationPermissionState: QADebugHomeState {
        didSet {
            guard !isSynchronizingState else { return }
            synchronizeLocationPermissionStateChange()
        }
    }
    @Published var selectedPhotoLibraryPermissionState: QADebugHomeState {
        didSet {
            guard !isSynchronizingState else { return }
            synchronizePhotoLibraryPermissionStateChange()
        }
    }
    @Published var statusMessage: String?

    private let repository: QADebugSettingsRepositoryProtocol
    private var isSynchronizingState = false

    init(
        repository: QADebugSettingsRepositoryProtocol
    ) {
        self.repository = repository
        self.skipOnboarding = repository.hasCompletedOnboarding
        self.selectedHomeState = .none
        self.selectedRecentState = .none
        self.selectedLocationPermissionState = .none
        self.selectedPhotoLibraryPermissionState = .none

        normalizeInitialRepositoryState(
            homeState: repository.qaHomeState,
            recentState: repository.qaRecentState,
            locationPermissionState: repository.qaLocationPermissionState,
            photoLibraryPermissionState: repository.qaPhotoLibraryPermissionState
        )
    }

    private func normalizeInitialRepositoryState(
        homeState: QADebugHomeState,
        recentState: QADebugHomeState,
        locationPermissionState: QADebugHomeState,
        photoLibraryPermissionState: QADebugHomeState
    ) {
        isSynchronizingState = true

        if locationPermissionState == .none {
            selectedLocationPermissionState = Self.defaultLocationPermissionState
            repository.qaLocationPermissionState = Self.defaultLocationPermissionState
        } else {
            selectedLocationPermissionState = locationPermissionState
        }

        if photoLibraryPermissionState == .none {
            selectedPhotoLibraryPermissionState = Self.defaultPhotoLibraryPermissionState
            repository.qaPhotoLibraryPermissionState = Self.defaultPhotoLibraryPermissionState
        } else {
            selectedPhotoLibraryPermissionState = photoLibraryPermissionState
        }

        if recentState == .none {
            selectedRecentState = Self.defaultRecentState
            repository.qaRecentState = Self.defaultRecentState
        } else {
            selectedRecentState = recentState
        }

        if homeState == .none {
            selectedHomeState = Self.defaultHomeState
            repository.qaHomeState = Self.defaultHomeState
        } else {
            selectedHomeState = homeState
        }

        isSynchronizingState = false
    }

    func resetOnboarding() {
        skipOnboarding = false
        repository.hasCompletedOnboarding = false
        statusMessage = "Onboarding will appear again after relaunch."
    }

    func clearQADebugState() {
        isSynchronizingState = true
        selectedHomeState = Self.defaultHomeState
        selectedRecentState = Self.defaultRecentState
        selectedLocationPermissionState = Self.defaultLocationPermissionState
        selectedPhotoLibraryPermissionState = Self.defaultPhotoLibraryPermissionState
        repository.qaHomeState = Self.defaultHomeState
        repository.qaRecentState = Self.defaultRecentState
        repository.qaLocationPermissionState = Self.defaultLocationPermissionState
        repository.qaPhotoLibraryPermissionState = Self.defaultPhotoLibraryPermissionState
        statusMessage = "QA Home state overrides reset to defaults."
        isSynchronizingState = false
    }

    func clearBlockingPermissionOverrides() {
        isSynchronizingState = true

        if selectedLocationPermissionState.isBlocking {
            selectedLocationPermissionState = Self.defaultLocationPermissionState
            repository.qaLocationPermissionState = Self.defaultLocationPermissionState
        }

        if selectedPhotoLibraryPermissionState.isBlocking {
            selectedPhotoLibraryPermissionState = Self.defaultPhotoLibraryPermissionState
            repository.qaPhotoLibraryPermissionState = Self.defaultPhotoLibraryPermissionState
        }

        if !selectedLocationPermissionState.isBlocking && !selectedPhotoLibraryPermissionState.isBlocking {
            if repository.qaHomeState == .none {
                selectedHomeState = Self.defaultHomeState
                repository.qaHomeState = Self.defaultHomeState
            }
        }

        statusMessage = "QA permission overrides cleared."
        isSynchronizingState = false
    }

    private func synchronizeHomeStateChange() {
        isSynchronizingState = true
        repository.qaHomeState = selectedHomeState

        if selectedHomeState != .none {
            if selectedLocationPermissionState.isBlocking {
                selectedLocationPermissionState = .none
                repository.qaLocationPermissionState = .none
            }

            if selectedPhotoLibraryPermissionState.isBlocking {
                selectedPhotoLibraryPermissionState = .none
                repository.qaPhotoLibraryPermissionState = .none
            }
        }

        statusMessage = "QA Home state changed to \(selectedHomeState.title)."
        isSynchronizingState = false
    }

    private func synchronizeRecentStateChange() {
        isSynchronizingState = true
        repository.qaRecentState = selectedRecentState
        statusMessage = "QA Recent image state changed to \(selectedRecentState.title)."
        isSynchronizingState = false
    }

    private func synchronizeLocationPermissionStateChange() {
        isSynchronizingState = true
        repository.qaLocationPermissionState = selectedLocationPermissionState

        if selectedLocationPermissionState.isBlocking {
            selectedHomeState = .none
            repository.qaHomeState = .none
        } else if !selectedLocationPermissionState.isBlocking && !selectedPhotoLibraryPermissionState.isBlocking {
            if repository.qaHomeState == .none {
                selectedHomeState = Self.defaultHomeState
                repository.qaHomeState = Self.defaultHomeState
            }
        }

        statusMessage = "QA Location permission debug state changed to \(selectedLocationPermissionState.title)."
        isSynchronizingState = false
    }

    private func synchronizePhotoLibraryPermissionStateChange() {
        isSynchronizingState = true
        repository.qaPhotoLibraryPermissionState = selectedPhotoLibraryPermissionState

        if selectedPhotoLibraryPermissionState.isBlocking {
            selectedHomeState = .none
            repository.qaHomeState = .none
        } else if !selectedLocationPermissionState.isBlocking && !selectedPhotoLibraryPermissionState.isBlocking {
            if repository.qaHomeState == .none {
                selectedHomeState = Self.defaultHomeState
                repository.qaHomeState = Self.defaultHomeState
            }
        }

        statusMessage = "QA Photo library permission debug state changed to \(selectedPhotoLibraryPermissionState.title)."
        isSynchronizingState = false
    }
}

