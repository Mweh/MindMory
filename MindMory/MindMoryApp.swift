import SwiftData
import SwiftUI

@main
struct MindMoryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let container = try! ModelContainer(for: AlbumEntity.self)

    var body: some Scene {
        WindowGroup {
            AppRootView(container: appDelegate.container)
                .modelContainer(container)
                .preferredColorScheme(.light)
        }
    }
}
