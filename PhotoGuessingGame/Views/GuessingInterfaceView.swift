import SwiftUI

struct GuessingInterfaceView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 25) {
            // Phase progress indicator
            PhaseProgressView()

            // Turn score
            if viewModel.turnScore > 0 {
                HStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)

                    Text("Turn: +\(viewModel.turnScore) \(viewModel.turnScore == 1 ? "point" : "points")")
                        .font(.headline)
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.2))
                )
            }

            // Phase-specific selector
            Group {
                switch viewModel.guessPhase {
                case .year:
                    YearSelectorView()
                case .month:
                    MonthSelectorView()
                case .day:
                    DaySelectorView()
                case .country:
                    CountrySelectorView()
                case .state:
                    StateSelectorView()
                case .city:
                    CitySelectorView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: viewModel.guessPhase)
        }
    }
}

// MARK: - Phase Progress View

struct PhaseProgressView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: 20) {
            ForEach(phases, id: \.self) { phase in
                PhaseIndicator(
                    phase: phase,
                    isActive: viewModel.guessPhase == phase,
                    isCompleted: isPhaseCompleted(phase)
                )
            }
        }
    }

    private var phases: [GuessPhase] {
        switch viewModel.gameMode {
        case .date:
            return [.year, .month, .day]
        case .location:
            return [.country, .state, .city]
        }
    }

    private func isPhaseCompleted(_ phase: GuessPhase) -> Bool {
        let phaseOrder: [GuessPhase]
        switch viewModel.gameMode {
        case .date:
            phaseOrder = [.year, .month, .day]
        case .location:
            phaseOrder = [.country, .state, .city]
        }

        guard let currentIndex = phaseOrder.firstIndex(of: viewModel.guessPhase),
              let phaseIndex = phaseOrder.firstIndex(of: phase) else {
            return false
        }

        return phaseIndex < currentIndex
    }
}

struct PhaseIndicator: View {
    let phase: GuessPhase
    let isActive: Bool
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 50, height: 50)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("+\(phase.points)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isActive ? .white : .gray)
                }
            }

            Text(phase.displayName)
                .font(.caption)
                .fontWeight(isActive ? .bold : .regular)
                .foregroundColor(isActive ? .white : .secondary)
        }
    }

    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

#Preview {
    VStack {
        GuessingInterfaceView()
    }
    .padding()
    .environmentObject(GameViewModel())
}
