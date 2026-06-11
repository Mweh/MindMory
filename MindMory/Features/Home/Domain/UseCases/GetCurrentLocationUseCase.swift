import Foundation

struct GetCurrentLocationUseCase {
    let repository: LocationRepositoryProtocol

    func execute() async throws -> CurrentLocationContext? {
        let status = await repository.authorizationStatus()
        switch status {
        case .granted:
            return try await repository.getCurrentLocation()
        case .notDetermined:
            guard await repository.requestAuthorization() == .granted else { return nil }
            return try await repository.getCurrentLocation()
        case .denied:
            return nil
        }
    }
}
