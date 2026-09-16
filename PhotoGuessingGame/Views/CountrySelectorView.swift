import SwiftUI

struct CountrySelectorView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 25) {
            Text("Where was this photo taken?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Select the country")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 15) {
                ForEach(viewModel.generateCountryOptions(), id: \.self) { country in
                    OptionButton(text: country) {
                        viewModel.submitGuess(country)
                    }
                }
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, 60)
        }
    }
}

#Preview {
    CountrySelectorView()
        .environmentObject(GameViewModel())
}
