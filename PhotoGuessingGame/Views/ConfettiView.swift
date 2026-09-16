import SwiftUI

struct ConfettiView: View {
    @Binding var isActive: Bool
    @State private var particles: [ConfettiParticle] = []

    private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink, .purple, .cyan]
    private let particleCount = 100

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiParticleView(particle: particle)
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    createParticles(in: geometry.size)
                }
            }
            .onAppear {
                if isActive {
                    createParticles(in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func createParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -100...(-50)),
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 8...15),
                rotation: Double.random(in: 0...360),
                duration: Double.random(in: 2...4),
                delay: Double.random(in: 0...1),
                finalY: size.height + 100
            )
        }
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let size: CGFloat
    let rotation: Double
    let duration: Double
    let delay: Double
    let finalY: CGFloat
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    @State private var offsetY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 0.6)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(x: particle.x, y: particle.y + offsetY)
            .onAppear {
                withAnimation(
                    Animation
                        .easeIn(duration: particle.duration)
                        .delay(particle.delay)
                ) {
                    offsetY = particle.finalY
                    rotation = particle.rotation + 720
                }

                withAnimation(
                    Animation
                        .easeIn(duration: 0.5)
                        .delay(particle.delay + particle.duration - 0.5)
                ) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Star Burst View (for correct answers)

struct StarBurstView: View {
    let isActive: Bool
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title)
                    .offset(starOffset(for: index))
                    .opacity(opacity)
            }
        }
        .scaleEffect(scale)
        .onChange(of: isActive) { _, newValue in
            if newValue {
                animate()
            }
        }
        .onAppear {
            if isActive {
                animate()
            }
        }
    }

    private func starOffset(for index: Int) -> CGSize {
        let angle = CGFloat(index) * (360.0 / 8.0) * .pi / 180
        let distance: CGFloat = 60 * scale
        return CGSize(
            width: Darwin.cos(angle) * distance,
            height: Darwin.sin(angle) * distance
        )
    }

    private func animate() {
        scale = 0
        opacity = 1

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            scale = 1
        }

        withAnimation(Animation.easeOut(duration: 0.5).delay(0.5)) {
            opacity = 0
        }
    }
}

#Preview {
    ZStack {
        Color.black
        ConfettiView(isActive: .constant(true))
    }
}
