import Foundation

extension Notification.Name {
    static let qaDebugSettingsDidChange = Notification.Name("qaDebugSettingsDidChange")
}

final class QADebugSettingsRepository: QADebugSettingsRepositoryProtocol {

    private enum Keys {
        static let qaDebugModeEnabled = "qaDebugModeEnabled"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let qaHomeState = "qaHomeState"
        static let qaRecentState = "qaRecentState"
        static let qaLocationPermissionState = "qaLocationPermissionState"
        static let qaPhotoLibraryPermissionState = "qaPhotoLibraryPermissionState"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var qaDebugModeEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.qaDebugModeEnabled) }
        set {
            userDefaults.set(newValue, forKey: Keys.qaDebugModeEnabled)
            notifyDebugSettingsChanged()
        }
    }

    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { userDefaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    var qaHomeState: QADebugHomeState {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.qaHomeState),
                  let state = QADebugHomeState(rawValue: rawValue) else {
                return .none
            }
            return state
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.qaHomeState)
            notifyDebugSettingsChanged()
        }
    }

    var qaRecentState: QADebugHomeState {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.qaRecentState),
                  let state = QADebugHomeState(rawValue: rawValue) else {
                return .none
            }
            return state
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.qaRecentState)
            notifyDebugSettingsChanged()
        }
    }

    var qaLocationPermissionState: QADebugHomeState {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.qaLocationPermissionState),
                  let state = QADebugHomeState(rawValue: rawValue) else {
                return .none
            }
            return state
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.qaLocationPermissionState)
            notifyDebugSettingsChanged()
        }
    }

    var qaPhotoLibraryPermissionState: QADebugHomeState {
        get {
            guard let rawValue = userDefaults.string(forKey: Keys.qaPhotoLibraryPermissionState),
                  let state = QADebugHomeState(rawValue: rawValue) else {
                return .none
            }
            return state
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: Keys.qaPhotoLibraryPermissionState)
            notifyDebugSettingsChanged()
        }
    }

    private func notifyDebugSettingsChanged() {
        NotificationCenter.default.post(name: .qaDebugSettingsDidChange, object: nil)
    }
}
