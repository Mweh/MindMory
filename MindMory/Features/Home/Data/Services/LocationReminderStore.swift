import Foundation

struct ReminderLocation: Codable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
}

final class LocationReminderStore {
    private let defaults = UserDefaults.standard
    private let keyLastLocation = "com.mindmory.lastReminderLocation"
    private let keyFirstLaunch = "com.mindmory.hasSentFirstLaunchNotification"

    var lastReminderLocation: ReminderLocation? {
        get {
            guard let data = defaults.data(forKey: keyLastLocation) else { return nil }
            return try? JSONDecoder().decode(ReminderLocation.self, from: data)
        }
        set {
            if let newValue = newValue, let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: keyLastLocation)
            } else {
                defaults.removeObject(forKey: keyLastLocation)
            }
        }
    }

    var hasSentFirstLaunchNotification: Bool {
        get {
            defaults.bool(forKey: keyFirstLaunch)
        }
        set {
            defaults.set(newValue, forKey: keyFirstLaunch)
        }
    }
}
