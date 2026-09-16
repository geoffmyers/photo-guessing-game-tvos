import SwiftUI

struct YearSelectorView: View {
    @EnvironmentObject var viewModel: GameViewModel

    private let columns = Array(repeating: GridItem(.fixed(140), spacing: 20), count: 4)

    var body: some View {
        VStack(spacing: 20) {
            Text("When was this photo taken?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Select the year")
                .font(.headline)
                .foregroundColor(.secondary)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.generateYearOptions(), id: \.self) { year in
                    GridButton(
                        title: "\(year)",
                        width: 140,
                        height: 80
                    ) {
                        viewModel.submitGuess(year)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    YearSelectorView()
        .environmentObject(GameViewModel())
}
