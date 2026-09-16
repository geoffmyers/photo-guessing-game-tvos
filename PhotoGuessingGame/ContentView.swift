import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Main content based on game phase
            switch viewModel.gamePhase {
            case .setup:
                SetupView()
                    .transition(.opacity)

            case .playing, .feedback:
                GameBoardView()
                    .transition(.opacity)

            case .victory:
                VictoryView()
                    .transition(.scale.combined(with: .opacity))

            case .noPhotos:
                NoPhotosView()
                    .transition(.opacity)
            }

            // Feedback overlay
            if viewModel.gamePhase == .feedback {
                FeedbackOverlayView()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gamePhase)
    }
}

// MARK: - No Photos View

struct NoPhotosView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "photo.stack")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("No More Photos!")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 20) {
                HStack(spacing: 60) {
                    PlayerScoreCard(player: viewModel.players[0])
                    PlayerScoreCard(player: viewModel.players[1])
                }
            }

            Text(tieMessage)
                .font(.title2)
                .foregroundColor(.secondary)

            Button(action: { viewModel.resetGame() }) {
                Label("Play Again", systemImage: "arrow.counterclockwise")
                    .font(.title2)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(60)
    }

    private var tieMessage: String {
        let p1 = viewModel.players[0]
        let p2 = viewModel.players[1]

        if p1.score > p2.score {
            return "\(p1.name) wins!"
        } else if p2.score > p1.score {
            return "\(p2.name) wins!"
        } else {
            return "It's a tie!"
        }
    }
}

struct PlayerScoreCard: View {
    let player: Player

    var body: some View {
        VStack(spacing: 10) {
            Text(player.name)
                .font(.title2)
                .fontWeight(.semibold)

            Text("\(player.score)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.blue)

            Text("points")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
