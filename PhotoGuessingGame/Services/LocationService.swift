import Foundation

class LocationService {

    private let baseURL = "https://nominatim.openstreetmap.org/reverse"
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 1.1 // Nominatim rate limit

    // MARK: - Reverse Geocoding

    func reverseGeocode(latitude: Double, longitude: Double) async throws -> PhotoLocation {
        // Respect rate limiting
        if let lastTime = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastTime)
            if elapsed < minimumRequestInterval {
                try await Task.sleep(nanoseconds: UInt64((minimumRequestInterval - elapsed) * 1_000_000_000))
            }
        }

        lastRequestTime = Date()

        // Build URL
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "zoom", value: "10"),
            URLQueryItem(name: "addressdetails", value: "1")
        ]

        guard let url = components.url else {
            throw LocationServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("PhotoGuessingGame/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LocationServiceError.requestFailed
        }

        let result = try JSONDecoder().decode(NominatimResponse.self, from: data)

        return PhotoLocation(
            country: result.address.country,
            state: result.address.state ?? result.address.region ?? result.address.province,
            city: result.address.city ?? result.address.town ?? result.address.village ?? result.address.municipality,
            latitude: latitude,
            longitude: longitude
        )
    }
}

// MARK: - Nominatim Response Models

private struct NominatimResponse: Decodable {
    let address: NominatimAddress

    enum CodingKeys: String, CodingKey {
        case address
    }
}

private struct NominatimAddress: Decodable {
    let country: String?
    let state: String?
    let region: String?
    let province: String?
    let city: String?
    let town: String?
    let village: String?
    let municipality: String?

    enum CodingKeys: String, CodingKey {
        case country
        case state
        case region
        case province
        case city
        case town
        case village
        case municipality
    }
}

// MARK: - Errors

enum LocationServiceError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for geocoding"
        case .requestFailed:
            return "Geocoding request failed"
        case .decodingFailed:
            return "Failed to decode geocoding response"
        }
    }
}
