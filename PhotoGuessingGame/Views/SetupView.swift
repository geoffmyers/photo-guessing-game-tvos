import SwiftUI

struct SetupView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var player1Name: String = ""
    @State private var player2Name: String = ""
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case player1, player2, mode, loadPhotos, startGame
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                // Title
                VStack(spacing: 10) {
                    Text("Photo Guessing Game")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("A two-player party game")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Player Names
                HStack(spacing: 80) {
                    PlayerNameInput(
                        label: "Player 1",
                        name: $player1Name,
                        placeholder: "Enter name",
                        color: .blue
                    )
                    .focused($focusedField, equals: .player1)
                    .onChange(of: player1Name) { _, newValue in
                        viewModel.setPlayerName(0, name: newValue)
                    }

                    PlayerNameInput(
                        label: "Player 2",
                        name: $player2Name,
                        placeholder: "Enter name",
                        color: .green
                    )
                    .focused($focusedField, equals: .player2)
                    .onChange(of: player2Name) { _, newValue in
                        viewModel.setPlayerName(1, name: newValue)
                    }
                }

                // Game Mode Selection
                VStack(spacing: 20) {
                    Text("Select Game Mode")
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 40) {
                        ForEach(GameMode.allCases) { mode in
                            GameModeButton(
                                mode: mode,
                                isSelected: viewModel.gameMode == mode,
                                isEnabled: modeEnabled(mode)
                            ) {
                                viewModel.setGameMode(mode)
                                viewModel.playClickSound()
                            }
                        }
                    }
                }
                .focused($focusedField, equals: .mode)

                // Photo Loader
                PhotoLoaderView()
                    .focused($focusedField, equals: .loadPhotos)

                // Start Button
                Button(action: startGame) {
                    HStack(spacing: 15) {
                        Image(systemName: "play.fill")
                        Text("Start Game")
                    }
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 20)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(!viewModel.canStartGame)
                .focused($focusedField, equals: .startGame)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 80)
        }
    }

    private func modeEnabled(_ mode: GameMode) -> Bool {
        switch mode {
        case .date:
            return viewModel.photosWithValidDate >= GameConstants.minimumPhotosRequired
        case .location:
            return viewModel.photosWithValidLocation >= GameConstants.minimumPhotosRequired
        }
    }

    private func startGame() {
        viewModel.startGame()
    }
}

// MARK: - Player Name Input

struct PlayerNameInput: View {
    let label: String
    @Binding var name: String
    let placeholder: String
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text(label)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(color)

            TextField(placeholder, text: $name)
                .textFieldStyle(.plain)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .frame(width: 440)
        }
    }
}

// MARK: - Game Mode Button

struct GameModeButton: View {
    let mode: GameMode
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                Image(systemName: mode.icon)
                    .font(.system(size: 50))

                Text(mode.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(mode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if !isEnabled {
                    Text("Not enough photos")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 20)
            .frame(width: 460, height: 280)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1.0 : 0.5)
        .disabled(!isEnabled)
    }
}

#Preview {
    SetupView()
        .environmentObject(GameViewModel())
}
