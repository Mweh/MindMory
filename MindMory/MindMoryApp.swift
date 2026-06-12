import SwiftData
import SwiftUI

@main
struct MindMoryApp: App {
    private let container = try! ModelContainer(for: AlbumEntity.self)

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modelContainer(container)
                .preferredColorScheme(.light)
        }
    }
}
