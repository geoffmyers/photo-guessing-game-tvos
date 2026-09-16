import Foundation
import SwiftUI

// MARK: - Game Phase

enum GamePhase: Equatable {
    case setup
    case playing
    case feedback
    case victory
    case noPhotos
}

// MARK: - Game Mode

enum GameMode: String, CaseIterable, Identifiable {
    case date = "date"
    case location = "location"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .date: return "When Was It?"
        case .location: return "Where Was It?"
        }
    }

    var description: String {
        switch self {
        case .date: return "Guess the year, month, and day"
        case .location: return "Guess the country, state, and city"
        }
    }

    var icon: String {
        switch self {
        case .date: return "calendar"
        case .location: return "mappin.and.ellipse"
        }
    }
}

// MARK: - Guess Phase

enum GuessPhase: String, Equatable {
    // Date mode phases
    case year
    case month
    case day

    // Location mode phases
    case country
    case state
    case city

    var displayName: String {
        rawValue.capitalized
    }

    var points: Int {
        switch self {
        case .year, .country: return 1
        case .month, .state: return 2
        case .day, .city: return 3
        }
    }

    var cumulativePoints: Int {
        switch self {
        case .year, .country: return 1
        case .month, .state: return 3
        case .day, .city: return 6
        }
    }

    static func initialPhase(for mode: GameMode) -> GuessPhase {
        switch mode {
        case .date: return .year
        case .location: return .country
        }
    }

    func nextPhase(for mode: GameMode) -> GuessPhase? {
        switch mode {
        case .date:
            switch self {
            case .year: return .month
            case .month: return .day
            case .day: return nil
            default: return nil
            }
        case .location:
            switch self {
            case .country: return .state
            case .state: return .city
            case .city: return nil
            default: return nil
            }
        }
    }

    var isFinalPhase: Bool {
        self == .day || self == .city
    }
}

// MARK: - Player

struct Player: Identifiable, Equatable {
    let id: Int
    var name: String
    var score: Int = 0

    static let defaultNames = ["Player 1", "Player 2"]
}

// MARK: - Photo

struct GamePhoto: Identifiable, Equatable {
    let id: UUID
    let imageData: Data?
    let imagePath: String?
    var date: PhotoDate?
    var location: PhotoLocation?
    var isUsed: Bool = false

    init(id: UUID = UUID(), imageData: Data? = nil, imagePath: String? = nil, date: PhotoDate? = nil, location: PhotoLocation? = nil) {
        self.id = id
        self.imageData = imageData
        self.imagePath = imagePath
        self.date = date
        self.location = location
    }

    var hasValidDate: Bool {
        date != nil
    }

    var hasValidLocation: Bool {
        guard let location = location else { return false }
        return location.country != nil
    }
}

struct PhotoDate: Equatable {
    let year: Int
    let month: Int
    let day: Int

    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        var components = DateComponents()
        components.month = month
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return "Unknown"
    }

    var formattedDate: String {
        "\(monthName) \(day), \(year)"
    }
}

struct PhotoLocation: Equatable {
    let country: String?
    let state: String?
    let city: String?
    let latitude: Double?
    let longitude: Double?

    var formattedLocation: String {
        [city, state, country].compactMap { $0 }.joined(separator: ", ")
    }
}

// MARK: - Current Guess

struct CurrentGuess: Equatable {
    var year: Int?
    var month: Int?
    var day: Int?
    var country: String?
    var state: String?
    var city: String?

    mutating func reset() {
        year = nil
        month = nil
        day = nil
        country = nil
        state = nil
        city = nil
    }
}

// MARK: - Feedback

struct GameFeedback: Equatable {
    let isCorrect: Bool
    let message: String
    let correctAnswer: String
    let pointsEarned: Int
    let isPerfect: Bool
    /// False for a correct answer that leads to another phase of the same turn.
    var endsTurn = true

    static let empty = GameFeedback(isCorrect: false, message: "", correctAnswer: "", pointsEarned: 0, isPerfect: false)
}

// MARK: - Game Constants

enum GameConstants {
    static let winningScore = 10
    static let feedbackDuration: Double = 2.0
    static let perfectScore = 6
    static let maxPhotosToLoad = 30
    static let minimumPhotosRequired = 3
}

// MARK: - Month Helper

enum Month: Int, CaseIterable {
    case january = 1
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december

    var name: String {
        switch self {
        case .january: return "January"
        case .february: return "February"
        case .march: return "March"
        case .april: return "April"
        case .may: return "May"
        case .june: return "June"
        case .july: return "July"
        case .august: return "August"
        case .september: return "September"
        case .october: return "October"
        case .november: return "November"
        case .december: return "December"
        }
    }

    var shortName: String {
        String(name.prefix(3))
    }
}
