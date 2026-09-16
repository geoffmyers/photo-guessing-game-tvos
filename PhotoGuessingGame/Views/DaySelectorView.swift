import SwiftUI

struct DaySelectorView: View {
    @EnvironmentObject var viewModel: GameViewModel

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.fixed(70), spacing: 8), count: 7)
    private let cellHeight: CGFloat = 48

    var body: some View {
        VStack(spacing: 20) {
            // Show already guessed year and month
            HStack(spacing: 20) {
                if let year = viewModel.currentGuess.year {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(String(year))
                    }
                }

                if let month = viewModel.currentGuess.month,
                   let monthEnum = Month(rawValue: month) {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(monthEnum.name)
                    }
                }
            }
            .font(.headline)

            Text("Select the day")
                .font(.headline)
                .fontWeight(.semibold)

            // Calendar grid
            VStack(spacing: 10) {
                // Weekday headers
                HStack(spacing: 8) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .frame(width: 70)
                    }
                }

                // Days grid
                LazyVGrid(columns: columns, spacing: 6) {
                    // Empty cells for offset. Their ids are negative so they
                    // cannot collide with the day buttons' ids (1...31): the
                    // grid drops views whose ids repeat, which lost days 1-4.
                    ForEach(-firstWeekdayOffset..<0, id: \.self) { _ in
                        Color.clear
                            .frame(width: 70, height: cellHeight)
                    }

                    // Day buttons
                    ForEach(1...daysInMonth, id: \.self) { day in
                        GridButton(
                            title: "\(day)",
                            width: 70,
                            height: cellHeight
                        ) {
                            viewModel.submitGuess(day)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var daysInMonth: Int {
        guard let month = viewModel.currentGuess.month,
              let year = viewModel.currentGuess.year else {
            return 31
        }
        return GameUtils.daysInMonth(month: month, year: year)
    }

    private var firstWeekdayOffset: Int {
        guard let month = viewModel.currentGuess.month,
              let year = viewModel.currentGuess.year else {
            return 0
        }
        return GameUtils.firstWeekdayOfMonth(month: month, year: year)
    }
}

#Preview {
    DaySelectorView()
        .environmentObject(GameViewModel())
}
