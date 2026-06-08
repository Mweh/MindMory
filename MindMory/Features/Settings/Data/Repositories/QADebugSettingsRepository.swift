import Foundation

final class QADebugSettingsRepository: QADebugSettingsRepositoryProtocol {

    private enum Keys {
        static let qaDebugModeEnabled = "qaDebugModeEnabled"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let debugHomeCardImagePath = "debugHomeCardImagePath"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var qaDebugModeEnabled: Bool {
        get { userDefaults.bool(forKey: Keys.qaDebugModeEnabled) }
        set { userDefaults.set(newValue, forKey: Keys.qaDebugModeEnabled) }
    }

    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { userDefaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    var debugHomeCardImagePath: String? {
        get { userDefaults.string(forKey: Keys.debugHomeCardImagePath) }
        set { userDefaults.set(newValue, forKey: Keys.debugHomeCardImagePath) }
    }
}
