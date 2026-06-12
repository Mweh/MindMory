import Foundation

final class SmartMemoryNotificationCooldownStore {
    private enum Keys {
        static let lastByContext = "smartMemoryNotifications.lastByContext"
        static let lastByAsset = "smartMemoryNotifications.lastByAsset"
    }

    private let userDefaults: UserDefaults
    private let contextCooldown: TimeInterval
    private let assetCooldown: TimeInterval

    init(
        userDefaults: UserDefaults = .standard,
        contextCooldown: TimeInterval = 6 * 60 * 60,
        assetCooldown: TimeInterval = 24 * 60 * 60
    ) {
        self.userDefaults = userDefaults
        self.contextCooldown = contextCooldown
        self.assetCooldown = assetCooldown
    }

    func canNotify(contextKey: String, assetLocalIdentifier: String, now: Date = Date()) -> Bool {
        let lastByContext = loadDates(forKey: Keys.lastByContext)
        if let lastContextDate = lastByContext[contextKey], now.timeIntervalSince(lastContextDate) < contextCooldown {
            return false
        }

        let lastByAsset = loadDates(forKey: Keys.lastByAsset)
        if let lastAssetDate = lastByAsset[assetLocalIdentifier], now.timeIntervalSince(lastAssetDate) < assetCooldown {
            return false
        }

        return true
    }

    func recordNotification(contextKey: String, assetLocalIdentifier: String, sentAt: Date = Date()) {
        var lastByContext = loadDates(forKey: Keys.lastByContext)
        lastByContext[contextKey] = sentAt
        saveDates(lastByContext, forKey: Keys.lastByContext)

        var lastByAsset = loadDates(forKey: Keys.lastByAsset)
        lastByAsset[assetLocalIdentifier] = sentAt
        saveDates(lastByAsset, forKey: Keys.lastByAsset)
    }

    private func loadDates(forKey key: String) -> [String: Date] {
        guard let data = userDefaults.data(forKey: key),
              let timestamps = try? JSONDecoder().decode([String: TimeInterval].self, from: data) else {
            return [:]
        }

        return timestamps.mapValues { Date(timeIntervalSince1970: $0) }
    }

    private func saveDates(_ dates: [String: Date], forKey key: String) {
        let timestamps = dates.mapValues(\.timeIntervalSince1970)
        guard let data = try? JSONEncoder().encode(timestamps) else { return }
        userDefaults.set(data, forKey: key)
    }
}
