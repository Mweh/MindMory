import SwiftUI
import Combine

enum AlbumViewState: Equatable { case loading, loaded([Memory]), empty, error(String) }
final class AlbumViewModel: ObservableObject {
    @Published private(set) var state: AlbumViewState = .loading
    @Published private(set) var showingFavoritesOnly = false
    private let getAlbumMemoriesUseCase: GetAlbumMemoriesUseCase
    private let getFavoriteMemoriesUseCase: GetFavoriteMemoriesUseCase
    init(getAlbumMemoriesUseCase: GetAlbumMemoriesUseCase, getFavoriteMemoriesUseCase: GetFavoriteMemoriesUseCase) { self.getAlbumMemoriesUseCase = getAlbumMemoriesUseCase; self.getFavoriteMemoriesUseCase = getFavoriteMemoriesUseCase }
    func load() { let memories = showingFavoritesOnly ? getFavoriteMemoriesUseCase.execute() : getAlbumMemoriesUseCase.execute(); state = memories.isEmpty ? .empty : .loaded(memories) }
    func toggleFavoriteFilter() { showingFavoritesOnly.toggle(); load() }
}
