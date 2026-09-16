import SwiftUI

struct StateSelectorView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 25) {
            // Show already guessed country
            if let country = viewModel.currentGuess.country {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Country: \(country)")
                        .fontWeight(.semibold)
                }
                .font(.headline)
            }

            Text("Select the state/region")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 15) {
                ForEach(viewModel.generateStateOptions(), id: \.self) { state in
                    OptionButton(text: state) {
                        viewModel.submitGuess(state)
                    }
                }
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    StateSelectorView()
        .environmentObject(GameViewModel())
}
