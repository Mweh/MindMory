import Foundation

protocol QADebugSettingsRepositoryProtocol: AnyObject {
    var qaDebugModeEnabled: Bool { get set }
    var hasCompletedOnboarding: Bool { get set }
    var debugHomeCardImagePath: String? { get set }
}
