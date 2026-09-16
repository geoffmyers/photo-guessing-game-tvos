import Foundation
import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var gamePhase: GamePhase = .setup
    @Published var gameMode: GameMode = .date
    @Published var players: [Player] = [
        Player(id: 0, name: "Player 1"),
        Player(id: 1, name: "Player 2")
    ]
    @Published var currentPlayerIndex: Int = 0
    @Published var photos: [GamePhoto] = []
    @Published var allPhotos: [GamePhoto] = []
    @Published var currentPhotoIndex: Int = 0
    @Published var guessPhase: GuessPhase = .year
    @Published var currentGuess: CurrentGuess = CurrentGuess()
    @Published var turnScore: Int = 0
    @Published var feedback: GameFeedback = .empty
    @Published var winner: Player?
    @Published var pendingWinner: Player?
    @Published var isTieBreaker: Bool = false
    @Published var isLoadingPhotos: Bool = false
    @Published var loadingProgress: Double = 0
    @Published var loadingMessage: String = ""

    // Location data extracted from all photos
    @Published var allCountries: [String] = []
    @Published var allStates: [String] = []
    @Published var allCities: [String] = []

    // Services
    private let soundService = SoundService()
    private let photoService = PhotoService()
    private let locationService = LocationService()

    // MARK: - Computed Properties

    var currentPlayer: Player {
        players[currentPlayerIndex]
    }

    var currentPhoto: GamePhoto? {
        guard currentPhotoIndex < photos.count else { return nil }
        return photos[currentPhotoIndex]
    }

    var photosWithValidDate: Int {
        allPhotos.filter { $0.hasValidDate }.count
    }

    var photosWithValidLocation: Int {
        allPhotos.filter { $0.hasValidLocation }.count
    }

    var canStartGame: Bool {
        let minPhotos = GameConstants.minimumPhotosRequired
        switch gameMode {
        case .date:
            return photosWithValidDate >= minPhotos
        case .location:
            return photosWithValidLocation >= minPhotos
        }
    }

    var remainingPhotos: Int {
        photos.filter { !$0.isUsed }.count
    }

    var photoCountText: String {
        "\(currentPhotoIndex + 1) / \(photos.count)"
    }

    // MARK: - Setup Actions

    func setPlayerName(_ playerId: Int, name: String) {
        guard playerId < players.count else { return }
        players[playerId].name = name.isEmpty ? Player.defaultNames[playerId] : name
    }

    func setGameMode(_ mode: GameMode) {
        gameMode = mode
        guessPhase = GuessPhase.initialPhase(for: mode)
    }

    // MARK: - Photo Loading

    func loadPhotos() async {
        isLoadingPhotos = true
        loadingProgress = 0
        loadingMessage = "Loading photos..."

        do {
            let loadedPhotos = try await photoService.loadPhotosFromLibrary(
                maxCount: GameConstants.maxPhotosToLoad,
                progressHandler: { [weak self] progress, message in
                    Task { @MainActor in
                        self?.loadingProgress = progress
                        self?.loadingMessage = message
                    }
                }
            )

            // Extract metadata for location mode
            loadingMessage = "Extracting metadata..."
            var processedPhotos: [GamePhoto] = []

            for (index, photo) in loadedPhotos.enumerated() {
                var updatedPhoto = photo

                // Extract location if GPS available
                if let lat = photo.location?.latitude, let lng = photo.location?.longitude {
                    if let locationInfo = try? await locationService.reverseGeocode(latitude: lat, longitude: lng) {
                        updatedPhoto.location = locationInfo
                    }
                }

                processedPhotos.append(updatedPhoto)
                loadingProgress = Double(index + 1) / Double(loadedPhotos.count)
                loadingMessage = "Processing \(index + 1)/\(loadedPhotos.count)..."
            }

            allPhotos = processedPhotos
            extractLocationData()

        } catch {
            print("Error loading photos: \(error)")
        }

        isLoadingPhotos = false
        loadingMessage = ""
    }

    private func extractLocationData() {
        var countries = Set<String>()
        var states = Set<String>()
        var cities = Set<String>()

        for photo in allPhotos {
            if let country = photo.location?.country {
                countries.insert(country)
            }
            if let state = photo.location?.state {
                states.insert(state)
            }
            if let city = photo.location?.city {
                cities.insert(city)
            }
        }

        allCountries = Array(countries).sorted()
        allStates = Array(states).sorted()
        allCities = Array(cities).sorted()
    }

    // MARK: - Game Flow

    func startGame() {
        // Filter photos based on game mode
        switch gameMode {
        case .date:
            photos = allPhotos.filter { $0.hasValidDate }
        case .location:
            photos = allPhotos.filter { $0.hasValidLocation }
        }

        // Shuffle photos
        photos.shuffle()

        // Reset game state
        currentPhotoIndex = 0
        currentPlayerIndex = 0
        players[0].score = 0
        players[1].score = 0
        guessPhase = GuessPhase.initialPhase(for: gameMode)
        currentGuess.reset()
        turnScore = 0
        winner = nil
        pendingWinner = nil
        isTieBreaker = false

        // Mark all photos as unused
        for i in 0..<photos.count {
            photos[i].isUsed = false
        }

        gamePhase = .playing
        soundService.playClick()
    }

    func submitGuess(_ value: Any) {
        guard let photo = currentPhoto else { return }

        let isCorrect = checkGuess(value, for: photo)

        if isCorrect {
            handleCorrectGuess()
        } else {
            handleWrongGuess(for: photo)
        }
    }

    private func checkGuess(_ value: Any, for photo: GamePhoto) -> Bool {
        switch guessPhase {
        case .year:
            guard let guessedYear = value as? Int,
                  let actualYear = photo.date?.year else { return false }
            return guessedYear == actualYear

        case .month:
            guard let guessedMonth = value as? Int,
                  let actualMonth = photo.date?.month else { return false }
            return guessedMonth == actualMonth

        case .day:
            guard let guessedDay = value as? Int,
                  let actualDay = photo.date?.day else { return false }
            return guessedDay == actualDay

        case .country:
            guard let guessedCountry = value as? String,
                  let actualCountry = photo.location?.country else { return false }
            return guessedCountry.lowercased() == actualCountry.lowercased()

        case .state:
            guard let guessedState = value as? String,
                  let actualState = photo.location?.state else { return false }
            return guessedState.lowercased() == actualState.lowercased()

        case .city:
            guard let guessedCity = value as? String,
                  let actualCity = photo.location?.city else { return false }
            return guessedCity.lowercased() == actualCity.lowercased()
        }
    }

    private func handleCorrectGuess() {
        turnScore += guessPhase.points

        // Check if this was the final phase
        if guessPhase.isFinalPhase {
            let isPerfect = turnScore == GameConstants.perfectScore
            feedback = GameFeedback(
                isCorrect: true,
                message: isPerfect ? "Perfect!" : "Correct!",
                correctAnswer: "",
                pointsEarned: turnScore,
                isPerfect: isPerfect
            )

            // Add turn score to player's total
            players[currentPlayerIndex].score += turnScore

            if isPerfect {
                soundService.playVictoryFanfare()
            } else {
                soundService.playCorrect()
            }

            gamePhase = .feedback

            // Check for victory after feedback
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.feedbackDuration) { [weak self] in
                self?.checkVictoryAndEndTurn()
            }
        } else {
            // Progress to next phase
            feedback = GameFeedback(
                isCorrect: true,
                message: "Correct!",
                correctAnswer: "",
                pointsEarned: guessPhase.points,
                isPerfect: false
            )

            soundService.playCorrect()
            gamePhase = .feedback

            DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.feedbackDuration) { [weak self] in
                guard let self = self else { return }
                if let nextPhase = self.guessPhase.nextPhase(for: self.gameMode) {
                    self.guessPhase = nextPhase
                }
                self.gamePhase = .playing
            }
        }

        // Update current guess
        updateCurrentGuess()
    }

    private func handleWrongGuess(for photo: GamePhoto) {
        let correctAnswer = getCorrectAnswerString(for: photo)

        // Add accumulated turn score to player's total (even on wrong answer)
        players[currentPlayerIndex].score += turnScore

        feedback = GameFeedback(
            isCorrect: false,
            message: "Wrong!",
            correctAnswer: correctAnswer,
            pointsEarned: turnScore,
            isPerfect: false
        )

        soundService.playIncorrect()
        gamePhase = .feedback

        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.feedbackDuration) { [weak self] in
            self?.checkVictoryAndEndTurn()
        }
    }

    private func getCorrectAnswerString(for photo: GamePhoto) -> String {
        switch gameMode {
        case .date:
            return photo.date?.formattedDate ?? "Unknown"
        case .location:
            return photo.location?.formattedLocation ?? "Unknown"
        }
    }

    private func updateCurrentGuess() {
        guard let photo = currentPhoto else { return }

        switch guessPhase {
        case .year:
            currentGuess.year = photo.date?.year
        case .month:
            currentGuess.month = photo.date?.month
        case .day:
            currentGuess.day = photo.date?.day
        case .country:
            currentGuess.country = photo.location?.country
        case .state:
            currentGuess.state = photo.location?.state
        case .city:
            currentGuess.city = photo.location?.city
        }
    }

    private func checkVictoryAndEndTurn() {
        let currentScore = players[currentPlayerIndex].score

        // Check for victory
        if currentScore >= GameConstants.winningScore {
            if pendingWinner == nil {
                // First player to reach winning score
                if currentPlayerIndex == 0 {
                    // Player 1 reached first, give Player 2 a chance (tie-breaker)
                    pendingWinner = players[0]
                    isTieBreaker = true
                    endTurn()
                } else {
                    // Player 2 won
                    declareWinner(players[1])
                }
            } else {
                // Already in tie-breaker
                let player1Score = players[0].score
                let player2Score = players[1].score

                if player2Score > player1Score {
                    declareWinner(players[1])
                } else if player1Score > player2Score {
                    declareWinner(players[0])
                } else {
                    // Still tied, continue
                    endTurn()
                }
            }
        } else {
            endTurn()
        }
    }

    private func declareWinner(_ player: Player) {
        winner = player
        gamePhase = .victory
        soundService.playVictoryFanfare()
    }

    private func endTurn() {
        // Mark current photo as used
        if currentPhotoIndex < photos.count {
            photos[currentPhotoIndex].isUsed = true
        }

        // Move to next photo
        currentPhotoIndex += 1

        // Check if we ran out of photos
        if currentPhotoIndex >= photos.count {
            // Determine winner by score
            if players[0].score > players[1].score {
                declareWinner(players[0])
            } else if players[1].score > players[0].score {
                declareWinner(players[1])
            } else {
                // Tie with no photos left
                gamePhase = .noPhotos
            }
            return
        }

        // Switch player
        currentPlayerIndex = (currentPlayerIndex + 1) % 2

        // Reset turn state
        turnScore = 0
        guessPhase = GuessPhase.initialPhase(for: gameMode)
        currentGuess.reset()

        gamePhase = .playing
    }

    // MARK: - Reset

    func resetGame() {
        gamePhase = .setup
        currentPhotoIndex = 0
        currentPlayerIndex = 0
        players[0].score = 0
        players[1].score = 0
        guessPhase = GuessPhase.initialPhase(for: gameMode)
        currentGuess.reset()
        turnScore = 0
        feedback = .empty
        winner = nil
        pendingWinner = nil
        isTieBreaker = false

        // Reset photo usage
        for i in 0..<photos.count {
            photos[i].isUsed = false
        }
    }

    func fullReset() {
        resetGame()
        allPhotos = []
        photos = []
        allCountries = []
        allStates = []
        allCities = []
    }

    // MARK: - Option Generation

    func generateYearOptions() -> [Int] {
        guard let correctYear = currentPhoto?.date?.year else { return [] }
        return GameUtils.generateYearOptions(correctYear: correctYear)
    }

    func generateDayOptions() -> [Int] {
        guard let photo = currentPhoto,
              let month = photo.date?.month,
              let year = photo.date?.year else { return [] }

        let daysInMonth = GameUtils.daysInMonth(month: month, year: year)
        return Array(1...daysInMonth)
    }

    func generateCountryOptions() -> [String] {
        guard let correctCountry = currentPhoto?.location?.country else { return [] }
        return GameUtils.generateLocationOptions(correctValue: correctCountry, allValues: allCountries)
    }

    func generateStateOptions() -> [String] {
        guard let correctState = currentPhoto?.location?.state else { return [] }
        // Filter states by current country if available
        let statesInCountry = allPhotos
            .filter { $0.location?.country == currentGuess.country }
            .compactMap { $0.location?.state }
        let uniqueStates = Array(Set(statesInCountry))
        return GameUtils.generateLocationOptions(correctValue: correctState, allValues: uniqueStates.isEmpty ? allStates : uniqueStates)
    }

    func generateCityOptions() -> [String] {
        guard let correctCity = currentPhoto?.location?.city else { return [] }
        // Filter cities by current state if available
        let citiesInState = allPhotos
            .filter { $0.location?.state == currentGuess.state }
            .compactMap { $0.location?.city }
        let uniqueCities = Array(Set(citiesInState))
        return GameUtils.generateLocationOptions(correctValue: correctCity, allValues: uniqueCities.isEmpty ? allCities : uniqueCities)
    }

    // MARK: - Sound

    func playClickSound() {
        soundService.playClick()
    }
}
