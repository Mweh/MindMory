import SwiftUI
import Combine

final class DependencyContainer: ObservableObject {
    private let memoryRepository: MemoryRepositoryProtocol
    private let reminderRepository: ReminderRepositoryProtocol
    private let permissionRepository: PermissionRepositoryProtocol
    private let contextRepository: ContextRepositoryProtocol

    init(
        memoryRepository: MemoryRepositoryProtocol = MockMemoryRepository(),
        reminderRepository: ReminderRepositoryProtocol = MockReminderRepository(),
        permissionRepository: PermissionRepositoryProtocol = NativePermissionRepository(),
        contextRepository: ContextRepositoryProtocol = MockContextRepository()
    ) {
        self.memoryRepository = memoryRepository
        self.reminderRepository = reminderRepository
        self.permissionRepository = permissionRepository
        self.contextRepository = contextRepository
    }

    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(
            pages: OnboardingPageCatalog.pages,
            requestLocationPermissionUseCase: RequestLocationPermissionUseCase(repository: permissionRepository),
            requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase(repository: permissionRepository),
            requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase(repository: permissionRepository)
        )
    }
    func makeHomeViewModel() -> HomeViewModel { HomeViewModel(memories: memoryRepository.fetchMemories()) }
    func makeAlbumListViewModel() -> AlbumListViewModel { AlbumListViewModel(albums: PreviewData.sampleAlbums) }
    func makeMemoryAlbumViewModel() -> MemoryAlbumViewModel { MemoryAlbumViewModel(loadAlbumPhotosUseCase: LoadAlbumPhotosUseCase(), createAlbumUseCase: CreateAlbumUseCase()) }
    func makeMemoryDetailViewModel(memory: Memory) -> MemoryDetailViewModel { MemoryDetailViewModel(memory: memory, saveJournalEntryUseCase: SaveJournalEntryUseCase(repository: memoryRepository), toggleFavoriteMemoryUseCase: ToggleFavoriteMemoryUseCase(repository: memoryRepository), generateShareableMemoryUseCase: GenerateShareableMemoryUseCase()) }
    func makeSettingsViewModel() -> SettingsViewModel { SettingsViewModel(permissionRepository: permissionRepository, requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase(repository: permissionRepository), requestLocationPermissionUseCase: RequestLocationPermissionUseCase(repository: permissionRepository), requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase(repository: permissionRepository), qaDebugSettingsRepository: QADebugSettingsRepository(), debugImageStorageService: DebugImageStorageService()) }
    func makeContextualTriggersViewModel() -> ContextualTriggersViewModel { ContextualTriggersViewModel(repository: contextRepository) }
}
