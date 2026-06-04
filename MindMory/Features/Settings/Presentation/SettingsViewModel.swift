import SwiftUI
import Combine

struct PermissionRowModel: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    var status: PermissionStatus
}

final class SettingsViewModel: ObservableObject {

    @Published private(set) var permissionRows: [PermissionRowModel]

    private let requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase
    private let requestLocationPermissionUseCase: RequestLocationPermissionUseCase
    private let requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase

    init(
        requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase,
        requestLocationPermissionUseCase: RequestLocationPermissionUseCase,
        requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase
    ) {
        self.requestNotificationPermissionUseCase = requestNotificationPermissionUseCase
        self.requestLocationPermissionUseCase = requestLocationPermissionUseCase
        self.requestCalendarPermissionUseCase = requestCalendarPermissionUseCase
        self.permissionRows = Self.defaultPermissionRows
    }

    func requestAll() {
        permissionRows[0].status = requestNotificationPermissionUseCase.execute()
        permissionRows[1].status = requestLocationPermissionUseCase.execute()
        permissionRows[2].status = requestCalendarPermissionUseCase.execute()
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
