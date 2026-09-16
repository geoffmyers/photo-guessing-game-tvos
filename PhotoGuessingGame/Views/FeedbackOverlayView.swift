import SwiftUI

struct FeedbackOverlayView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // Feedback card
            VStack(spacing: 30) {
                // Icon
                ZStack {
                    Circle()
                        .fill(viewModel.feedback.isCorrect ? Color.green : Color.red)
                        .frame(width: 120, height: 120)
                        .shadow(color: (viewModel.feedback.isCorrect ? Color.green : Color.red).opacity(0.5), radius: 20)

                    Image(systemName: viewModel.feedback.isCorrect ? "checkmark" : "xmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showConfetti ? 1.0 : 0.5)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showConfetti)

                // Message
                Text(viewModel.feedback.message)
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(viewModel.feedback.isCorrect ? .green : .red)

                // Points earned (if any)
                if viewModel.feedback.pointsEarned > 0 {
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)

                        Text("+\(viewModel.feedback.pointsEarned) \(viewModel.feedback.pointsEarned == 1 ? "point" : "points")")
                            .fontWeight(.bold)
                    }
                    .font(.title)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        Capsule()
                            .fill(Color.yellow.opacity(0.2))
                    )
                }

                // Correct answer (if wrong)
                if !viewModel.feedback.isCorrect && !viewModel.feedback.correctAnswer.isEmpty {
                    VStack(spacing: 10) {
                        Text("Correct answer:")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text(viewModel.feedback.correctAnswer)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                }

                // Tie-breaker info
                if viewModel.isTieBreaker {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)

                        Text("Tie-Breaker Round!")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.2))
                    )
                }

                // Next player, only when this answer ends the turn: a correct
                // answer before the last phase keeps the same player guessing.
                if viewModel.feedback.endsTurn {
                    let nextPlayerIndex = (viewModel.currentPlayerIndex + 1) % 2
                    let nextPlayer = viewModel.players[nextPlayerIndex]

                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.blue)

                        Text("Next: \(nextPlayer.name)")
                    }
                    .font(.title3)
                    .foregroundColor(.secondary)
                }
            }
            .padding(60)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(white: 0.15))
                    .shadow(color: .black.opacity(0.5), radius: 30)
            )

            // Confetti for perfect score
            if viewModel.feedback.isPerfect {
                ConfettiView(isActive: $showConfetti)
            }
        }
        .onAppear {
            showConfetti = true
        }
    }
}

#Preview {
    ZStack {
        Color.black
        FeedbackOverlayView()
            .environmentObject({
                let vm = GameViewModel()
                vm.feedback = GameFeedback(
                    isCorrect: true,
                    message: "Perfect!",
                    correctAnswer: "",
                    pointsEarned: 6,
                    isPerfect: true
                )
                return vm
            }())
    }
}
