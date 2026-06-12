import Foundation

struct SmartMemoryNotificationPayload: Equatable {
    static let notificationType = "smartMemory"

    let assetLocalIdentifier: String
    let contextKey: String
    let latitude: Double?
    let longitude: Double?

    var userInfo: [AnyHashable: Any] {
        var payload: [AnyHashable: Any] = [
            "type": Self.notificationType,
            "assetLocalIdentifier": assetLocalIdentifier,
            "contextKey": contextKey
        ]

        if let latitude {
            payload["latitude"] = latitude
        }

        if let longitude {
            payload["longitude"] = longitude
        }

        return payload
    }

    init(assetLocalIdentifier: String, contextKey: String, latitude: Double? = nil, longitude: Double? = nil) {
        self.assetLocalIdentifier = assetLocalIdentifier
        self.contextKey = contextKey
        self.latitude = latitude
        self.longitude = longitude
    }

    init?(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String,
              type == Self.notificationType,
              let assetLocalIdentifier = userInfo["assetLocalIdentifier"] as? String,
              let contextKey = userInfo["contextKey"] as? String else {
            return nil
        }

        self.assetLocalIdentifier = assetLocalIdentifier
        self.contextKey = contextKey
        self.latitude = userInfo["latitude"] as? Double
        self.longitude = userInfo["longitude"] as? Double
    }
}
