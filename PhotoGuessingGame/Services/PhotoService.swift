import Foundation
import Photos
import UIKit

class PhotoService {

    typealias ProgressHandler = (Double, String) -> Void

    // MARK: - Photo Loading

    func loadPhotosFromLibrary(maxCount: Int, progressHandler: ProgressHandler?) async throws -> [GamePhoto] {
        // Request authorization
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)

        guard status == .authorized || status == .limited else {
            throw PhotoServiceError.notAuthorized
        }

        progressHandler?(0.1, "Accessing photo library...")

        // Fetch recent photos
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = maxCount

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var photos: [GamePhoto] = []
        let total = min(assets.count, maxCount)

        for i in 0..<total {
            let asset = assets.object(at: i)

            progressHandler?(Double(i) / Double(total), "Loading photo \(i + 1)/\(total)...")

            if let photo = await loadPhoto(from: asset) {
                photos.append(photo)
            }
        }

        progressHandler?(1.0, "Complete!")

        return photos
    }

    private func loadPhoto(from asset: PHAsset) async -> GamePhoto? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true

            let targetSize = CGSize(width: 1920, height: 1080) // TV resolution

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                guard let image = image,
                      let imageData = image.jpegData(compressionQuality: 0.8) else {
                    continuation.resume(returning: nil)
                    return
                }

                // Extract date
                let date = asset.creationDate.map { date in
                    let calendar = Calendar.current
                    return PhotoDate(
                        year: calendar.component(.year, from: date),
                        month: calendar.component(.month, from: date),
                        day: calendar.component(.day, from: date)
                    )
                }

                // Extract location
                var location: PhotoLocation?
                if let assetLocation = asset.location {
                    location = PhotoLocation(
                        country: nil,
                        state: nil,
                        city: nil,
                        latitude: assetLocation.coordinate.latitude,
                        longitude: assetLocation.coordinate.longitude
                    )
                }

                let photo = GamePhoto(
                    id: UUID(),
                    imageData: imageData,
                    date: date,
                    location: location
                )

                continuation.resume(returning: photo)
            }
        }
    }

    // MARK: - Demo Photos (for testing without photo library)

    func loadDemoPhotos() -> [GamePhoto] {
        // Generate demo photos with random dates and locations
        var photos: [GamePhoto] = []

        let cities = [
            ("New York", "New York", "United States"),
            ("Los Angeles", "California", "United States"),
            ("London", "England", "United Kingdom"),
            ("Paris", "Île-de-France", "France"),
            ("Tokyo", "Tokyo", "Japan"),
            ("Sydney", "New South Wales", "Australia"),
            ("Berlin", "Berlin", "Germany"),
            ("Rome", "Lazio", "Italy"),
            ("Toronto", "Ontario", "Canada"),
            ("Barcelona", "Catalonia", "Spain")
        ]

        for i in 0..<10 {
            let year = Int.random(in: 2015...2024)
            let month = Int.random(in: 1...12)
            let day = Int.random(in: 1...28)
            let cityInfo = cities[i % cities.count]

            let photo = GamePhoto(
                id: UUID(),
                imageData: nil,
                imagePath: "demo_\(i)",
                date: PhotoDate(year: year, month: month, day: day),
                location: PhotoLocation(
                    country: cityInfo.2,
                    state: cityInfo.1,
                    city: cityInfo.0,
                    latitude: nil,
                    longitude: nil
                )
            )

            photos.append(photo)
        }

        return photos
    }
}

// MARK: - Errors

enum PhotoServiceError: Error, LocalizedError {
    case notAuthorized
    case loadFailed
    case noPhotosAvailable

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Photo library access not authorized"
        case .loadFailed:
            return "Failed to load photos"
        case .noPhotosAvailable:
            return "No photos available"
        }
    }
}
