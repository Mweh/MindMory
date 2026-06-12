import Foundation
import UserNotifications

final class SmartMemoryNotificationCoordinator {
    private let permissionRepository: PermissionRepositoryProtocol
    private let contextRepository: ContextRepositoryProtocol
    private let findContextualMemoryUseCase: FindContextualMemoryUseCase
    private let cooldownStore: SmartMemoryNotificationCooldownStore
    private let notificationCenter: UNUserNotificationCenter
    private let maximumNotificationDistance: Double = 500
    private let minimumNotificationConfidenceScore = 70
    private var isScheduling = false

    init(
        permissionRepository: PermissionRepositoryProtocol,
        contextRepository: ContextRepositoryProtocol,
        findContextualMemoryUseCase: FindContextualMemoryUseCase,
        cooldownStore: SmartMemoryNotificationCooldownStore,
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.permissionRepository = permissionRepository
        self.contextRepository = contextRepository
        self.findContextualMemoryUseCase = findContextualMemoryUseCase
        self.cooldownStore = cooldownStore
        self.notificationCenter = notificationCenter
    }

    func evaluateAndScheduleIfNeeded() async {
        guard !isScheduling else { return }
        isScheduling = true
        defer { isScheduling = false }

        guard contextRepository.fetchTriggerSettings().locationBasedReminders else { return }
        guard await permissionRepository.notificationStatus() == .granted else { return }
        guard await permissionRepository.locationStatus() == .granted else { return }

        let result = await findContextualMemoryUseCase.execute()
        guard case .loaded(let contextualMemory) = result else { return }
        guard shouldNotify(for: contextualMemory) else { return }

        let contextKey = makeContextKey(for: contextualMemory)
        guard cooldownStore.canNotify(
            contextKey: contextKey,
            assetLocalIdentifier: contextualMemory.assetLocalIdentifier
        ) else { return }

        let payload = SmartMemoryNotificationPayload(
            assetLocalIdentifier: contextualMemory.assetLocalIdentifier,
            contextKey: contextKey,
            latitude: contextualMemory.context.currentLocation?.latitude,
            longitude: contextualMemory.context.currentLocation?.longitude
        )

        await scheduleNotification(payload: payload, contextualMemory: contextualMemory)
    }

    private func shouldNotify(for contextualMemory: ContextualMemory) -> Bool {
        guard let event = contextualMemory.context.currentEvent,
              event.isHappening(at: contextualMemory.context.now) else {
            return false
        }

        guard let distanceMeters = contextualMemory.distanceMeters,
              distanceMeters <= maximumNotificationDistance else {
            return false
        }

        return contextualMemory.notificationConfidenceScore >= minimumNotificationConfidenceScore
    }

    private func scheduleNotification(payload: SmartMemoryNotificationPayload, contextualMemory: ContextualMemory) async {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle(for: contextualMemory)
        content.body = notificationBody(for: contextualMemory)
        content.sound = .default
        content.userInfo = payload.userInfo

        let identifier = "smartMemory.\(payload.contextKey).\(payload.assetLocalIdentifier)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        do {
            try await notificationCenter.add(request)
            cooldownStore.recordNotification(
                contextKey: payload.contextKey,
                assetLocalIdentifier: payload.assetLocalIdentifier
            )
        } catch {
            // Local notification scheduling failures should not block the app UI.
        }
    }

    private func makeContextKey(for contextualMemory: ContextualMemory) -> String {
        guard let location = contextualMemory.context.currentLocation else {
            return "asset:\(contextualMemory.assetLocalIdentifier)"
        }

        let latBucket = Int((location.latitude * 1000).rounded())
        let lonBucket = Int((location.longitude * 1000).rounded())
        return "\(latBucket):\(lonBucket)"
    }

    private func notificationTitle(for contextualMemory: ContextualMemory) -> String {
        if contextualMemory.context.currentEvent != nil {
            return "A memory from this moment"
        }

        return "A memory is nearby"
    }

    private func notificationBody(for contextualMemory: ContextualMemory) -> String {
        if let event = contextualMemory.context.currentEvent {
            return "You’re in \(event.title). Here’s something connected to now."
        }

        return "You’re near a place connected to this photo."
    }
}
