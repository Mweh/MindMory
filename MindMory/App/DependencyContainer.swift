import SwiftUI
import Combine
import EventKit
import UserNotifications

@MainActor
final class DependencyContainer: ObservableObject {
    let appRouter: AppRouter

    private let memoryRepository: MemoryRepositoryProtocol
    private let reminderRepository: ReminderRepositoryProtocol
    private let permissionRepository: PermissionRepositoryProtocol
    private let contextRepository: ContextRepositoryProtocol
    private let locationRepository: LocationRepositoryProtocol
    private let eventRepository: EventRepositoryProtocol
    private let photoLibraryRepository: PhotoLibraryRepositoryProtocol
    private let qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol
    private let smartMemoryNotificationDelegate: SmartMemoryNotificationDelegate
    private let smartMemoryNotificationStore: SmartMemoryNotificationCooldownStore
    private let smartMemoryNotificationCoordinator: SmartMemoryNotificationCoordinator
    private let calendarNotificationCoordinator: CalendarNotificationCoordinator

    convenience init() {
        // One shared store so permission state is consistent across all repos.
        let sharedEventStore = EKEventStore()
        let qaDebugRepository = QADebugSettingsRepository()
        self.init(
            memoryRepository: MockMemoryRepository(),
            reminderRepository: MockReminderRepository(),
            permissionRepository: NativePermissionRepository(eventStore: sharedEventStore),
            contextRepository: MockContextRepository(),
            locationRepository: CoreLocationRepository(),
            eventRepository: EventKitRepository(),
            photoLibraryRepository: PhotoLibraryRepository(),
            qaDebugSettingsRepository: qaDebugRepository,
            calendarRepository: CalendarRepository(store: sharedEventStore)
        )
    }

    init(
        memoryRepository: MemoryRepositoryProtocol,
        reminderRepository: ReminderRepositoryProtocol,
        permissionRepository: PermissionRepositoryProtocol,
        contextRepository: ContextRepositoryProtocol,
        locationRepository: LocationRepositoryProtocol,
        eventRepository: EventRepositoryProtocol,
        photoLibraryRepository: PhotoLibraryRepositoryProtocol,
        qaDebugSettingsRepository: QADebugSettingsRepositoryProtocol,
        calendarRepository: CalendarRepositoryProtocol = CalendarRepository()
    ) {
        self.appRouter = AppRouter()
        self.memoryRepository = memoryRepository
        self.reminderRepository = reminderRepository
        self.permissionRepository = permissionRepository
        self.contextRepository = contextRepository
        self.locationRepository = locationRepository
        self.eventRepository = eventRepository
        self.photoLibraryRepository = photoLibraryRepository
        self.qaDebugSettingsRepository = qaDebugSettingsRepository
        self.smartMemoryNotificationDelegate = SmartMemoryNotificationDelegate(appRouter: appRouter)
        self.smartMemoryNotificationStore = SmartMemoryNotificationCooldownStore()
        self.smartMemoryNotificationCoordinator = SmartMemoryNotificationCoordinator(
            permissionRepository: permissionRepository,
            contextRepository: contextRepository,
            findContextualMemoryUseCase: Self.makeFindContextualMemoryUseCase(
                locationRepository: locationRepository,
                eventRepository: eventRepository,
                photoLibraryRepository: photoLibraryRepository
            ),
            cooldownStore: smartMemoryNotificationStore
        )
        let calendarRepository: CalendarRepositoryProtocol = CalendarRepository()
        self.calendarNotificationCoordinator = CalendarNotificationCoordinator(
            permissionRepository: permissionRepository,
            fetchUpcomingCalendarEventsUseCase: FetchUpcomingCalendarEventsUseCase(repository: calendarRepository)
        )

    }

    func configureNotificationHandling() {
        UNUserNotificationCenter.current().delegate = smartMemoryNotificationDelegate
    }

    func startSmartMemoryNotifications() async {
        await smartMemoryNotificationCoordinator.evaluateAndScheduleIfNeeded()
    }
    
    func syncCalendarNotifications() async {
        await calendarNotificationCoordinator.scheduleUpcomingEventNotifications()
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(
            pages: OnboardingPageCatalog.pages,
            requestLocationPermissionUseCase: RequestLocationPermissionUseCase(repository: permissionRepository),
            requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase(repository: permissionRepository),
            requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase(repository: permissionRepository)
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchLocationPhotoListsUseCase: FetchLocationPhotoListsUseCase(repository: photoLibraryRepository),
            getCurrentLocationUseCase: GetCurrentLocationUseCase(repository: locationRepository),
            qaDebugSettingsRepository: qaDebugSettingsRepository
        )
    }

    func makeAlbumListViewModel() -> AlbumListViewModel {
        AlbumListViewModel()
    }

    func makeMemoryAlbumCreationViewModel() -> MemoryAlbumCreationViewModel {
        MemoryAlbumCreationViewModel(
            loadAlbumPhotosUseCase: LoadAlbumPhotosUseCase(),
            createAlbumUseCase: CreateAlbumUseCase()
        )
    }

    func makeMemoryDetailViewModel(memory: Memory) -> MemoryDetailViewModel {
        MemoryDetailViewModel(
            memory: memory,
            saveJournalEntryUseCase: SaveJournalEntryUseCase(repository: memoryRepository),
            toggleFavoriteMemoryUseCase: ToggleFavoriteMemoryUseCase(repository: memoryRepository),
            generateShareableMemoryUseCase: GenerateShareableMemoryUseCase()
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            permissionRepository: permissionRepository,
            requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase(repository: permissionRepository),
            requestLocationPermissionUseCase: RequestLocationPermissionUseCase(repository: permissionRepository),
            requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase(repository: permissionRepository),
            qaDebugSettingsRepository: qaDebugSettingsRepository
        )
    }

    func makeContextualTriggersViewModel() -> ContextualTriggersViewModel {
        ContextualTriggersViewModel(repository: contextRepository)
    }

    private static func makeFindContextualMemoryUseCase(
        locationRepository: LocationRepositoryProtocol,
        eventRepository: EventRepositoryProtocol,
        photoLibraryRepository: PhotoLibraryRepositoryProtocol
    ) -> FindContextualMemoryUseCase {
        FindContextualMemoryUseCase(
            getCurrentLocationUseCase: GetCurrentLocationUseCase(repository: locationRepository),
            getCurrentEventUseCase: GetCurrentEventUseCase(repository: eventRepository),
            fetchPhotoAssetsUseCase: FetchPhotoAssetsUseCase(repository: photoLibraryRepository),
            rankCandidatesUseCase: RankContextualMemoryCandidatesUseCase()
        )
    }
}
