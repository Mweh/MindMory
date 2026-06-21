import Foundation
import UserNotifications

final class SmartMemoryNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let appRouter: AppRouter

    init(appRouter: AppRouter) {
        self.appRouter = appRouter
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        print("Notification delivered")
        return [.banner, .list, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        print("Notification tapped")
        guard let payload = SmartMemoryNotificationPayload(
            userInfo: response.notification.request.content.userInfo
        ) else { return }

        await MainActor.run {
            appRouter.openMemories(assetLocalIdentifier: payload.assetLocalIdentifier)
        }
    }
}
