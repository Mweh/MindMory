import Combine
import Foundation

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: MainTab = .home
    @Published var routedAssetLocalIdentifier: String?

    func openMemories(assetLocalIdentifier: String) {
        selectedTab = .home
        routedAssetLocalIdentifier = assetLocalIdentifier
    }

    func consumeRoutedAssetLocalIdentifier() -> String? {
        let identifier = routedAssetLocalIdentifier
        routedAssetLocalIdentifier = nil
        return identifier
    }
}
