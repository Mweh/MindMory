import SwiftUI
import Combine
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
    private let contextualMemoryCacheRepository: ContextualMemoryCacheRepositoryProtocol
    private let smartMemoryNotificationDelegate: SmartMemoryNotificationDelegate
    private let smartMemoryNotificationStore: SmartMemoryNotificationCooldownStore
    private let smartMemoryNotificationCoordinator: SmartMemoryNotificationCoordinator

    convenience init() {
        self.init(
            memoryRepository: MockMemoryRepository(),
            reminderRepository: MockReminderRepository(),
            permissionRepository: NativePermissionRepository(),
            contextRepository: MockContextRepository(),
            locationRepository: CoreLocationRepository(),
            eventRepository: EventKitRepository(),
            photoLibraryRepository: PhotoLibraryRepository(),
            contextualMemoryCacheRepository: UserDefaultsContextualMemoryCacheRepository()
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
        contextualMemoryCacheRepository: ContextualMemoryCacheRepositoryProtocol
    ) {
        self.appRouter = AppRouter()
        self.memoryRepository = memoryRepository
        self.reminderRepository = reminderRepository
        self.permissionRepository = permissionRepository
        self.contextRepository = contextRepository
        self.locationRepository = locationRepository
        self.eventRepository = eventRepository
        self.photoLibraryRepository = photoLibraryRepository
        self.contextualMemoryCacheRepository = contextualMemoryCacheRepository
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
    }

    func configureNotificationHandling() {
        UNUserNotificationCenter.current().delegate = smartMemoryNotificationDelegate
    }

    func startSmartMemoryNotifications() async {
        await smartMemoryNotificationCoordinator.evaluateAndScheduleIfNeeded()
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
            memories: memoryRepository.fetchMemories(),
            findContextualMemoryUseCase: Self.makeFindContextualMemoryUseCase(
                locationRepository: locationRepository,
                eventRepository: eventRepository,
                photoLibraryRepository: photoLibraryRepository
            ),
            getCurrentLocationUseCase: GetCurrentLocationUseCase(repository: locationRepository),
            getCurrentEventUseCase: GetCurrentEventUseCase(repository: eventRepository),
            contextualMemoryCacheRepository: contextualMemoryCacheRepository,
            qaDebugSettingsRepository: QADebugSettingsRepository()
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
            qaDebugSettingsRepository: QADebugSettingsRepository(),
            debugImageStorageService: DebugImageStorageService()
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
