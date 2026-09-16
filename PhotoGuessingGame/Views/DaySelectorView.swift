import SwiftUI

struct DaySelectorView: View {
    @EnvironmentObject var viewModel: GameViewModel

    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.fixed(70), spacing: 8), count: 7)

    var body: some View {
        VStack(spacing: 20) {
            // Show already guessed year and month
            HStack(spacing: 20) {
                if let year = viewModel.currentGuess.year {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(year)")
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
                .font(.title2)
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
                LazyVGrid(columns: columns, spacing: 8) {
                    // Empty cells for offset
                    ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                        Color.clear
                            .frame(width: 70, height: 60)
                    }

                    // Day buttons
                    ForEach(1...daysInMonth, id: \.self) { day in
                        GridButton(
                            title: "\(day)",
                            width: 70,
                            height: 60
                        ) {
                            viewModel.submitGuess(day)
                        }
                    }
                }
            }
            .padding(.horizontal, 60)
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
