import UIKit
import CoreLocation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // We hold a shared DependencyContainer to keep background managers alive
    // even if the app was launched in the background without UI.
    let container = DependencyContainer()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // If launched due to a location event in background
        if let _ = launchOptions?[.location] {
            Task {
                await container.startDistanceReminders()
            }
        }
        
        return true
    }
}
