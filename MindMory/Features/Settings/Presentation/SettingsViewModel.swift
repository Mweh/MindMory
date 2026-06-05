import SwiftUI
import Combine

struct PermissionRowModel: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    var status: PermissionStatus
}

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published private(set) var permissionRows: [PermissionRowModel]
    @Published private(set) var isRequestingPermissions = false

    private let permissionRepository: PermissionRepositoryProtocol
    private let requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase
    private let requestLocationPermissionUseCase: RequestLocationPermissionUseCase
    private let requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase

    init(
        permissionRepository: PermissionRepositoryProtocol,
        requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase,
        requestLocationPermissionUseCase: RequestLocationPermissionUseCase,
        requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase
    ) {
        self.permissionRepository = permissionRepository
        self.requestNotificationPermissionUseCase = requestNotificationPermissionUseCase
        self.requestLocationPermissionUseCase = requestLocationPermissionUseCase
        self.requestCalendarPermissionUseCase = requestCalendarPermissionUseCase
        self.permissionRows = Self.defaultPermissionRows

        Task {
            await refreshStatuses()
        }
    }

    func requestAll() async {
        guard !isRequestingPermissions else {
            return
        }

        isRequestingPermissions = true
        permissionRows[0].status = await requestNotificationPermissionUseCase.execute()
        permissionRows[1].status = await requestLocationPermissionUseCase.execute()
        permissionRows[2].status = await requestCalendarPermissionUseCase.execute()
        isRequestingPermissions = false
    }

    func refreshStatuses() async {
        permissionRows[0].status = await permissionRepository.notificationStatus()
        permissionRows[1].status = await permissionRepository.locationStatus()
        permissionRows[2].status = await permissionRepository.calendarStatus()
    }

    private static var defaultPermissionRows: [PermissionRowModel] {
        [
            PermissionRowModel(
                title: "Notifications",
                description: "Receive thoughtful reminders at the right moment.",
                status: .notDetermined
            ),
            PermissionRowModel(
                title: "Location",
                description: "Understand meaningful places without storing more than needed.",
                status: .notDetermined
            ),
            PermissionRowModel(
                title: "Calendar",
                description: "Use EventKit context for gatherings and important plans.",
                status: .notDetermined
            )
        ]
    }
}
