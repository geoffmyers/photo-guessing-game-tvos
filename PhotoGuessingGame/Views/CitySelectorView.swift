import SwiftUI

struct CitySelectorView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 25) {
            // Show already guessed country and state
            HStack(spacing: 20) {
                if let country = viewModel.currentGuess.country {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(country)
                    }
                }

                if let state = viewModel.currentGuess.state {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(state)
                    }
                }
            }
            .font(.headline)

            Text("Select the city")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 15) {
                ForEach(viewModel.generateCityOptions(), id: \.self) { city in
                    OptionButton(text: city) {
                        viewModel.submitGuess(city)
                    }
                }
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, 60)
        }
    }
}

#Preview {
    CitySelectorView()
        .environmentObject(GameViewModel())
}
