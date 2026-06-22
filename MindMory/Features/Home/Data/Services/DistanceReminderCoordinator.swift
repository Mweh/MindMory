import Foundation
import CoreLocation
import UserNotifications
import Combine

final class DistanceReminderCoordinator {
    private let permissionRepository: PermissionRepositoryProtocol
    private let locationRepository: LocationRepositoryProtocol
    private let store: LocationReminderStore
    private let notificationCenter: UNUserNotificationCenter
    private var isEvaluating = false
    private var cancellables = Set<AnyCancellable>()

    init(
        permissionRepository: PermissionRepositoryProtocol,
        locationRepository: LocationRepositoryProtocol,
        store: LocationReminderStore = LocationReminderStore(),
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.permissionRepository = permissionRepository
        self.locationRepository = locationRepository
        self.store = store
        self.notificationCenter = notificationCenter

        NotificationCenter.default.publisher(for: NSNotification.Name("SignificantLocationChanged"))
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo,
                      let clLocation = userInfo["location"] as? CLLocation else { return }
                
                Task {
                    await self.evaluateLocationUpdate(clLocation)
                }
            }
            .store(in: &cancellables)
    }

    func startMonitoringIfEnabled() async {
        guard await permissionRepository.locationStatus() == .granted else { return }
        locationRepository.startMonitoringSignificantLocationChanges()
        
        if !store.hasSentFirstLaunchNotification {
            await scheduleFirstLaunchNotification()
        }
    }

    private func evaluateLocationUpdate(_ location: CLLocation) async {
        guard !isEvaluating else { return }
        isEvaluating = true
        defer { isEvaluating = false }

        guard await permissionRepository.notificationStatus() == .granted else { return }

        // Distance & Cooldown Logic
        if let lastLocation = store.lastReminderLocation {
            let lastCLLocation = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
            let distance = location.distance(from: lastCLLocation)
            let timeSinceLastReminder = Date().timeIntervalSince(lastLocation.timestamp)
            
            print("--- LOCATION UPDATE LOG ---")
            print("Current coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            print("Last reminder coordinates: \(lastLocation.latitude), \(lastLocation.longitude)")
            print("Computed distance: \(distance) meters")
            print("Cooldown status: \(timeSinceLastReminder / 60) minutes elapsed (needs 30 minutes)")
            
            let isDistanceMet = distance >= 1000
            let isCooldownMet = timeSinceLastReminder >= 30 * 60
            
            if isDistanceMet && isCooldownMet {
                print("Notification scheduling attempted: YES")
                let placemarkName = await locationRepository.getPlacemarkName(for: location)
                await scheduleMovementNotification(for: location, locationName: placemarkName)
            } else {
                print("Notification scheduling attempted: NO (DistanceMet: \(isDistanceMet), CooldownMet: \(isCooldownMet))")
            }
            print("---------------------------")
        } else {
            // Failsafe if it somehow never triggered first launch
            print("No last reminder location, but received significant location change. Evaluating first launch.")
            if !store.hasSentFirstLaunchNotification {
                await scheduleFirstLaunchNotification()
            }
        }
    }

    private func scheduleFirstLaunchNotification() async {
        guard await permissionRepository.notificationStatus() == .granted else { return }
        
        // Grab current location immediately if possible
        let locationContext = try? await locationRepository.getCurrentLocation()
        guard let location = locationContext else { return }

        print("First-launch notification scheduled")
        
        store.lastReminderLocation = ReminderLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            timestamp: Date()
        )
        store.hasSentFirstLaunchNotification = true

        let content = UNMutableNotificationContent()
        content.title = "MindMory"
        content.body = "Capture your first memory here. Take a photo of this moment."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "distanceReminder.firstLaunch",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        try? await notificationCenter.add(request)
    }

    private func scheduleMovementNotification(for location: CLLocation, locationName: String?) async {
        print("Notification scheduled")
        
        store.lastReminderLocation = ReminderLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: Date()
        )

        let content = UNMutableNotificationContent()
        content.title = "MindMory"
        
        if let name = locationName, !name.isEmpty {
            content.body = "You've arrived at \(name). Capture this moment with a photo."
        } else {
            content.body = "You're somewhere new. Capture this moment with a photo."
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "distanceReminder.movement.\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        try? await notificationCenter.add(request)
    }
}
