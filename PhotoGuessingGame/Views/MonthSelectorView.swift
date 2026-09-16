import SwiftUI

struct MonthSelectorView: View {
    @EnvironmentObject var viewModel: GameViewModel

    private let columns = Array(repeating: GridItem(.fixed(140), spacing: 15), count: 4)

    var body: some View {
        VStack(spacing: 20) {
            // Show already guessed year
            if let year = viewModel.currentGuess.year {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Year: \(year)")
                        .fontWeight(.semibold)
                }
                .font(.headline)
            }

            Text("Select the month")
                .font(.title2)
                .fontWeight(.semibold)

            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(Month.allCases, id: \.rawValue) { month in
                    GridButton(
                        title: month.shortName,
                        subtitle: nil,
                        width: 140,
                        height: 70
                    ) {
                        viewModel.submitGuess(month.rawValue)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    MonthSelectorView()
        .environmentObject(GameViewModel())
}
