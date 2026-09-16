import Foundation

enum GameUtils {

    /// Generate 8 year options including the correct year
    static func generateYearOptions(correctYear: Int) -> [Int] {
        var options = Set<Int>()
        options.insert(correctYear)

        // Add years within a reasonable range (±10 years, not before 1990 and
        // not in the future). The range must still hold the answer and at
        // least eight years: with a flat 1990 floor, a photo from before 1983
        // left too few years and the loop below never ended, and one from
        // before 1980 made the range empty and crashed.
        let currentYear = Calendar.current.component(.year, from: Date())
        let maxYear = max(correctYear, min(currentYear, correctYear + 10))
        let minYear = min(max(1990, correctYear - 10), maxYear - 7, correctYear)

        while options.count < 8 {
            let randomYear = Int.random(in: minYear...maxYear)
            options.insert(randomYear)
        }

        return Array(options).sorted()
    }

    /// Generate location options (5 options including the correct one)
    static func generateLocationOptions(correctValue: String, allValues: [String], count: Int = 5) -> [String] {
        var options = Set<String>()
        options.insert(correctValue)

        // Add other values from the pool
        let otherValues = allValues.filter { $0.lowercased() != correctValue.lowercased() }
        let shuffled = otherValues.shuffled()

        for value in shuffled {
            if options.count >= count { break }
            options.insert(value)
        }

        return Array(options).shuffled()
    }

    /// Get the number of days in a given month
    static func daysInMonth(month: Int, year: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month

        guard let date = Calendar.current.date(from: components),
              let range = Calendar.current.range(of: .day, in: .month, for: date) else {
            return 31
        }

        return range.count
    }

    /// Get weekday for the first day of a month (0 = Sunday)
    static func firstWeekdayOfMonth(month: Int, year: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let date = Calendar.current.date(from: components) else {
            return 0
        }

        return Calendar.current.component(.weekday, from: date) - 1
    }

    /// Format a score with proper pluralization
    static func formatScore(_ score: Int) -> String {
        score == 1 ? "1 point" : "\(score) points"
    }

    /// Calculate progress percentage through guess phases
    static func phaseProgress(phase: GuessPhase, mode: GameMode) -> Double {
        switch mode {
        case .date:
            switch phase {
            case .year: return 0.0
            case .month: return 0.33
            case .day: return 0.66
            default: return 0.0
            }
        case .location:
            switch phase {
            case .country: return 0.0
            case .state: return 0.33
            case .city: return 0.66
            default: return 0.0
            }
        }
    }
}
