import Foundation
import Photos
import Vision

#if canImport(UIKit)
import UIKit
#endif

public protocol PhotoAnalysisService {
    func analyzeFaces(in asset: PHAsset) async throws -> Int
}

public final class DefaultPhotoAnalysisService: PhotoAnalysisService {
    public init() {}
    
    public func analyzeFaces(in asset: PHAsset) async throws -> Int {
        return try await Task.detached {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            
            var resultImage: CGImage?
            var resultOrientation: CGImagePropertyOrientation = .up
            var resultError: Error?
            
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { image, info in
                if let image = image {
                    #if canImport(UIKit)
                    resultImage = image.cgImage
                    switch image.imageOrientation {
                    case .up: resultOrientation = .up
                    case .upMirrored: resultOrientation = .upMirrored
                    case .down: resultOrientation = .down
                    case .downMirrored: resultOrientation = .downMirrored
                    case .left: resultOrientation = .left
                    case .leftMirrored: resultOrientation = .leftMirrored
                    case .right: resultOrientation = .right
                    case .rightMirrored: resultOrientation = .rightMirrored
                    @unknown default: resultOrientation = .up
                    }
                    #endif
                } else if let error = info?[PHImageErrorKey] as? Error {
                    resultError = error
                }
            }
            
            guard let cgImage = resultImage else {
                throw resultError ?? NSError(domain: "PhotoAnalysisService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not obtain CGImage"])
            }
            
            let request = VNDetectFaceRectanglesRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: resultOrientation, options: [:])
            try handler.perform([request])
            
            let faceCount = request.results?.count ?? 0
            return faceCount
        }.value
    }
}
