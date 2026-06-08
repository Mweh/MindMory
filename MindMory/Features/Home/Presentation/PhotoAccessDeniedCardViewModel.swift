import Combine
import Photos
import SwiftUI
import UIKit

@MainActor
final class PhotoAccessDeniedCardViewModel: ObservableObject {

    @Published private(set) var authorizationStatus: PHAuthorizationStatus
    @Published private(set) var buttonTitle: String

    init() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        self.authorizationStatus = status
        self.buttonTitle = Self.makeButtonTitle(for: status)
    }

    func didTapAllowPhotoAccess() {
        switch authorizationStatus {
        case .notDetermined:
            requestPhotoAccess()

        case .denied, .restricted:
            openAppSettings()

        case .authorized, .limited:
            break

        @unknown default:
            break
        }
    }

    func refreshAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        authorizationStatus = status
        buttonTitle = Self.makeButtonTitle(for: status)
    }

    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            Task { @MainActor in
                self?.authorizationStatus = status
                self?.buttonTitle = Self.makeButtonTitle(for: status)
            }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(url)
    }

    private static func makeButtonTitle(for status: PHAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "Allow Photo Access"
        case .denied, .restricted:
            return "Open Settings"
        case .authorized, .limited:
            return "Photo Access Allowed"
        @unknown default:
            return "Open Settings"
        }
    }
}
