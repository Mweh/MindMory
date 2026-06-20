import Foundation

enum QADebugHomeState: String, CaseIterable, Identifiable {
    case none
    case loadedOne
    case loadedTwo
    case loadedThree
    case loadedFavorite
    case empty
    case error
    case permissionRequiredLocation
    case permissionRequiredPhotoLibrary
    case permissionDeniedLocation
    case permissionDeniedPhotoLibrary
    case permissionGrantedLocation
    case permissionGrantedPhotoLibrary

    var id: String { rawValue }

    var isBlocking: Bool {
        switch self {
        case .permissionGrantedLocation,
             .permissionGrantedPhotoLibrary,
             .none,
             .loadedOne,
             .loadedTwo,
             .loadedThree,
             .loadedFavorite,
             .empty,
             .error:
            return false
        case .permissionRequiredLocation,
             .permissionRequiredPhotoLibrary,
             .permissionDeniedLocation,
             .permissionDeniedPhotoLibrary:
            return true
        }
    }

    var title: String {
        switch self {
        case .none:
            return "None"
        case .loadedOne:
            return "Loaded 1 placeholder"
        case .loadedTwo:
            return "Loaded 2 placeholders"
        case .loadedThree:
            return "Loaded 3 placeholders"
        case .loadedFavorite:
            return "Loaded favorite photo"
        case .empty:
            return "Empty state"
        case .error:
            return "Error state"
        case .permissionRequiredLocation:
            return "Permission required: Location"
        case .permissionRequiredPhotoLibrary:
            return "Permission required: Photo library"
        case .permissionDeniedLocation:
            return "Permission denied: Location"
        case .permissionDeniedPhotoLibrary:
            return "Permission denied: Photo library"
        case .permissionGrantedLocation:
            return "Permission granted: Location"
        case .permissionGrantedPhotoLibrary:
            return "Permission granted: Photo library"
        }
    }

    var description: String {
        switch self {
        case .none:
            return "No QA home debug state applied."
        case .loadedOne:
            return "Show one debug placeholder memory card."
        case .loadedTwo:
            return "Show one card and two debug nearby placeholders."
        case .loadedThree:
            return "Show one card and three debug nearby placeholders."
        case .loadedFavorite:
            return "Show a favorite debug memory in the Home card."
        case .empty:
            return "Show an empty nearby photos state."
        case .error:
            return "Show a debug load error state."
        case .permissionRequiredLocation:
            return "Show the location permission request screen."
        case .permissionRequiredPhotoLibrary:
            return "Show the photo library permission request screen."
        case .permissionDeniedLocation:
            return "Show the denied location permission screen."
        case .permissionDeniedPhotoLibrary:
            return "Show the denied photo library permission screen."
        case .permissionGrantedLocation:
            return "Simulate granted location permission and let the Home state render normally."
        case .permissionGrantedPhotoLibrary:
            return "Simulate granted photo library permission and let the Home state render normally."
        }
    }
}

protocol QADebugSettingsRepositoryProtocol: AnyObject {
    var qaDebugModeEnabled: Bool { get set }
    var hasCompletedOnboarding: Bool { get set }
    var qaHomeState: QADebugHomeState { get set }
    var qaRecentState: QADebugHomeState { get set }
    var qaLocationPermissionState: QADebugHomeState { get set }
    var qaPhotoLibraryPermissionState: QADebugHomeState { get set }
}
