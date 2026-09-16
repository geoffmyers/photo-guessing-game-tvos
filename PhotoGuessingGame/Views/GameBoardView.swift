import SwiftUI

struct GameBoardView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: 0) {
            // Left Player Panel
            PlayerPanelView(
                player: viewModel.players[0],
                isActive: viewModel.currentPlayerIndex == 0,
                isTieBreaker: viewModel.isTieBreaker && viewModel.currentPlayerIndex == 0,
                isPendingWinner: viewModel.pendingWinner?.id == viewModel.players[0].id,
                accentColor: .blue
            )
            .frame(width: 280)

            // Center - Photo and Guessing Interface
            VStack(spacing: 30) {
                // Game mode indicator
                HStack {
                    Image(systemName: viewModel.gameMode.icon)
                    Text(viewModel.gameMode.displayName)
                }
                .font(.title3)
                .foregroundColor(.secondary)

                // Photo Display
                PhotoDisplayView()
                    .frame(maxHeight: 500)

                // Guessing Interface
                GuessingInterfaceView()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)

            // Right Player Panel
            PlayerPanelView(
                player: viewModel.players[1],
                isActive: viewModel.currentPlayerIndex == 1,
                isTieBreaker: viewModel.isTieBreaker && viewModel.currentPlayerIndex == 1,
                isPendingWinner: viewModel.pendingWinner?.id == viewModel.players[1].id,
                accentColor: .green
            )
            .frame(width: 280)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    GameBoardView()
        .environmentObject(GameViewModel())
}
