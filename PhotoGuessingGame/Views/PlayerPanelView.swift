import SwiftUI

struct PlayerPanelView: View {
    let player: Player
    let isActive: Bool
    let isTieBreaker: Bool
    let isPendingWinner: Bool
    let accentColor: Color

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Player name
            Text(player.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isActive ? accentColor : .secondary)

            // Score
            VStack(spacing: 5) {
                Text("\(player.score)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(isActive ? .white : .gray)

                Text("points")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Progress to win
            ProgressBar(
                progress: Double(player.score) / Double(GameConstants.winningScore),
                color: accentColor
            )
            .frame(height: 10)
            .padding(.horizontal, 20)

            // Status badges
            VStack(spacing: 10) {
                if isActive {
                    ActivePlayerBadge(color: accentColor)
                }

                if isTieBreaker {
                    TieBreakerBadge()
                }

                if isPendingWinner {
                    PendingWinnerBadge()
                }
            }

            Spacer()
        }
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isActive ? accentColor.opacity(0.15) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isActive ? accentColor.opacity(0.5) : Color.clear, lineWidth: 3)
        )
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let progress: Double
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray.opacity(0.3))

                // Progress
                RoundedRectangle(cornerRadius: 5)
                    .fill(color)
                    .frame(width: geometry.size.width * min(progress, 1.0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
            }
        }
    }
}

// MARK: - Status Badges

struct ActivePlayerBadge: View {
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .scaleEffect(1.5)
                        .opacity(0.5)
                )

            Text("YOUR TURN")
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.2))
        )
    }
}

struct TieBreakerBadge: View {
    var body: some View {
        Text("TIE-BREAKER!")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.orange)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.orange.opacity(0.2))
            )
    }
}

struct PendingWinnerBadge: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)

            Text("TO BEAT")
                .font(.caption)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.2))
        )
    }
}

#Preview {
    HStack {
        PlayerPanelView(
            player: Player(id: 0, name: "Alice", score: 6),
            isActive: true,
            isTieBreaker: false,
            isPendingWinner: false,
            accentColor: .blue
        )

        PlayerPanelView(
            player: Player(id: 1, name: "Bob", score: 4),
            isActive: false,
            isTieBreaker: false,
            isPendingWinner: false,
            accentColor: .green
        )
    }
    .frame(height: 500)
    .padding()
}
