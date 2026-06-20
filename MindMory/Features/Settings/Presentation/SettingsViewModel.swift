import SwiftUI
import Combine

struct PermissionRowModel: Identifiable, Equatable {
    let id = UUID()
    let area: SettingsAccessArea
    let title: String
    let description: String
    var status: PermissionStatus
}

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published private(set) var permissionRows: [PermissionRowModel]
    @Published private(set) var isRequestingPermissions = false
    @Published var requestingArea: SettingsAccessArea? = nil
    @Published var preferences = PhotoReminderSettings.default

    private let permissionRepository: PermissionRepositoryProtocol
    private let requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase
    private let requestLocationPermissionUseCase: RequestLocationPermissionUseCase
    private let requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase

    private let qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol

    var qaDebugModeEnabled: Bool {
        get { qaDebugSettingsRepository.qaDebugModeEnabled }
        set {
            qaDebugSettingsRepository.qaDebugModeEnabled = newValue
            objectWillChange.send()
        }
    }

    func makeQADebugToolsViewModel() -> QADebugToolsViewModel {
        QADebugToolsViewModel(repository: qaDebugSettingsRepository)
    }

    var allAccessGranted: Bool {
        permissionRows.allSatisfy { $0.status == .granted }
    }

    var hasDeniedAccess: Bool {
        permissionRows.contains { $0.status == .denied }
    }

    func status(for area: SettingsAccessArea) -> PermissionStatus {
        permissionRows.first(where: { $0.area == area })?.status ?? .notDetermined
    }

    func actionTitle(for area: SettingsAccessArea) -> String {
        switch status(for: area) {
        case .granted:
            return "Enabled"
        case .notDetermined:
            return "Allow access"
        case .denied:
            return "Open settings"
        }
    }

    func requestAccess(for area: SettingsAccessArea) async {
        requestingArea = area
        let status: PermissionStatus

        switch area {
        case .notifications:
            status = await requestNotificationPermissionUseCase.execute()
        case .location:
            status = await requestLocationPermissionUseCase.execute()
        case .calendar:
            status = await requestCalendarPermissionUseCase.execute()
        }

        updatePermissionRow(for: area, status: status)
        requestingArea = nil
    }

    private func updatePermissionRow(for area: SettingsAccessArea, status: PermissionStatus) {
        guard let index = permissionRows.firstIndex(where: { $0.area == area }) else {
            return
        }

        permissionRows[index].status = status
    }

    func clearLocationCategories() {
        var updated = preferences
        updated.location.selectedCategories = []
        preferences = updated
    }

    func clearScheduleCategories() {
        var updated = preferences
        updated.schedule.selectedCategories = []
        preferences = updated
    }

    init(
        permissionRepository: PermissionRepositoryProtocol,
        requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase,
        requestLocationPermissionUseCase: RequestLocationPermissionUseCase,
        requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase,
        qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    ) {
        self.permissionRepository = permissionRepository
        self.requestNotificationPermissionUseCase = requestNotificationPermissionUseCase
        self.requestLocationPermissionUseCase = requestLocationPermissionUseCase
        self.requestCalendarPermissionUseCase = requestCalendarPermissionUseCase
        self.qaDebugSettingsRepository = qaDebugSettingsRepository
        self.permissionRows = Self.defaultPermissionRows

        Task {
            await refreshStatuses()
        }
    }

    func refreshStatuses() async {
        updatePermissionRow(for: .notifications, status: await permissionRepository.notificationStatus())
        updatePermissionRow(for: .location, status: await permissionRepository.locationStatus())
        updatePermissionRow(for: .calendar, status: await permissionRepository.calendarStatus())
    }

    func toggleLocationCategory(_ category: PointOfInterestCategory) {
        var updated = preferences

        if updated.location.selectedCategories.contains(category) {
            updated.location.selectedCategories.remove(category)
        } else {
            updated.location.selectedCategories.insert(category)
        }

        preferences = updated
    }

    func toggleScheduleCategory(_ category: CalendarContextCategory) {
        var updated = preferences

        if updated.schedule.selectedCategories.contains(category) {
            updated.schedule.selectedCategories.remove(category)
        } else {
            updated.schedule.selectedCategories.insert(category)
        }

        preferences = updated
    }

    func setLocationNotificationTiming(_ timing: LocationNotificationTiming) {
        var updated = preferences
        switch timing {
        case .arrival:
            updated.location.notifyOnArrival = true
            updated.location.notifyAfterShortStay = false
        case .afterShortStay:
            updated.location.notifyOnArrival = false
            updated.location.notifyAfterShortStay = true
        }
        preferences = updated
    }

    var sampleNotificationTitle: String {
        switch preferences.message.tone {
        case .warm:
            return "This moment might be worth keeping"
        case .calm:
            return "A photo reminder is ready"
        case .concise:
            return "Take a photo"
        }
    }

    var sampleNotificationBody: String {
        var segments = [String]()

        if preferences.message.includesPlaceName {
            segments.append("You are somewhere memorable")
        }

        if preferences.message.includesEventTitle {
            segments.append("your plan looks meaningful")
        }

        if preferences.message.explainsTriggerReason {
            segments.append("MindMory noticed a context you care about")
        }

        if segments.isEmpty {
            return "MindMory will keep the notification short and minimal."
        }

        return segments.joined(separator: ", ") + "."
    }

    private static var defaultPermissionRows: [PermissionRowModel] {
        [
            PermissionRowModel(
                area: .notifications,
                title: "Notifications",
                description: "Receive thoughtful reminders at the right moment.",
                status: .notDetermined
            ),
            PermissionRowModel(
                area: .location,
                title: "Location",
                description: "Understand meaningful places without storing more than needed.",
                status: .notDetermined
            ),
            PermissionRowModel(
                area: .calendar,
                title: "Calendar",
                description: "Use EventKit context for gatherings and important plans.",
                status: .notDetermined
            )
        ]
    }
}
