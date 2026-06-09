import Foundation

final class DebugImageStorageService {

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func saveHomeCardImage(data: Data) throws -> String {
        let fileURL = try debugImageURL()
        try data.write(to: fileURL, options: [.atomic])
        return fileURL.path
    }

    func removeImage(path: String?) {
        guard let path else { return }
        try? fileManager.removeItem(atPath: path)
    }

    func imageURL(path: String?) -> URL? {
        guard let path else { return nil }
        let url = URL(fileURLWithPath: path)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    private func debugImageURL() throws -> URL {
        let documentsURL = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let folderURL = documentsURL.appendingPathComponent("QADebug", isDirectory: true)
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(
                at: folderURL,
                withIntermediateDirectories: true
            )
        }

        return folderURL.appendingPathComponent("home-card-debug-image.data")
    }
}
