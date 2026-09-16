import SwiftUI

struct VictoryView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showConfetti = false
    @State private var trophyScale: CGFloat = 0.5
    @State private var trophyRotation: Double = -10

    var body: some View {
        ZStack {
            // Background gradient
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.15, blue: 0.4),
                    Color(red: 0.1, green: 0.05, blue: 0.2)
                ]),
                center: .center,
                startRadius: 100,
                endRadius: 800
            )
            .ignoresSafeArea()

            // Confetti
            ConfettiView(isActive: $showConfetti)

            VStack(spacing: 40) {
                // Trophy icon
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 120))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 20)
                }
                .scaleEffect(trophyScale)
                .rotationEffect(.degrees(trophyRotation))

                // Winner announcement
                VStack(spacing: 15) {
                    Text("WINNER!")
                        .font(.system(size: 60, weight: .black))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    if let winner = viewModel.winner {
                        Text(winner.name)
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Final scores
                HStack(spacing: 80) {
                    FinalScoreCard(
                        player: viewModel.players[0],
                        isWinner: viewModel.winner?.id == viewModel.players[0].id,
                        color: .blue
                    )

                    Text("vs")
                        .font(.title)
                        .foregroundColor(.secondary)

                    FinalScoreCard(
                        player: viewModel.players[1],
                        isWinner: viewModel.winner?.id == viewModel.players[1].id,
                        color: .green
                    )
                }

                // Play again button
                Button(action: { viewModel.resetGame() }) {
                    HStack(spacing: 15) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 18)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.top, 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                trophyScale = 1.0
                trophyRotation = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}

// MARK: - Final Score Card

struct FinalScoreCard: View {
    let player: Player
    let isWinner: Bool
    let color: Color

    var body: some View {
        VStack(spacing: 15) {
            if isWinner {
                Image(systemName: "crown.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
            }

            Text(player.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(isWinner ? .white : .secondary)

            Text("\(player.score)")
                .font(.system(size: 70, weight: .bold, design: .rounded))
                .foregroundColor(isWinner ? color : .gray)

            Text("points")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isWinner ? color.opacity(0.2) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isWinner ? color : Color.clear, lineWidth: 3)
        )
    }
}

#Preview {
    VictoryView()
        .environmentObject({
            let vm = GameViewModel()
            vm.winner = vm.players[0]
            vm.players[0].score = 12
            vm.players[1].score = 8
            return vm
        }())
}
