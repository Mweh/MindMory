import Foundation

struct GetCurrentEventUseCase {
    let repository: EventRepositoryProtocol

    func execute(at date: Date) async throws -> CurrentEventContext? {
        let status = await repository.authorizationStatus()
        switch status {
        case .granted:
            return try await repository.getCurrentEvent(at: date)
        case .notDetermined:
            guard await repository.requestAuthorization() == .granted else { return nil }
            return try await repository.getCurrentEvent(at: date)
        case .denied:
            return nil
        }
    }
}
