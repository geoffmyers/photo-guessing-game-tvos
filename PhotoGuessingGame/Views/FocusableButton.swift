import SwiftUI

struct FocusableButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.isFocused) private var isFocused

    var body: some View {
        Button(action: action) {
            content()
                .scaleEffect(isFocused ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFocused)
        }
        .buttonStyle(TVFocusableButtonStyle())
    }
}

// MARK: - TV Focusable Button Style

struct TVFocusableButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Grid Button

struct GridButton: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    @Environment(\.isFocused) private var isFocused

    init(
        title: String,
        subtitle: String? = nil,
        isSelected: Bool = false,
        width: CGFloat = 120,
        height: CGFloat = 80,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.width = width
        self.height = height
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(borderColor, lineWidth: isFocused ? 4 : 0)
            )
            .scaleEffect(isFocused ? 1.1 : 1.0)
            .shadow(color: isFocused ? .blue.opacity(0.5) : .clear, radius: 10)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }

    private var backgroundColor: Color {
        if isSelected {
            return .green.opacity(0.3)
        } else if isFocused {
            return .blue.opacity(0.3)
        } else {
            return Color.white.opacity(0.1)
        }
    }

    private var borderColor: Color {
        if isSelected {
            return .green
        } else if isFocused {
            return .blue
        } else {
            return .clear
        }
    }
}

// MARK: - Option Button

struct OptionButton: View {
    let text: String
    let action: () -> Void

    @Environment(\.isFocused) private var isFocused

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title3)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isFocused ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 3)
                )
                .scaleEffect(isFocused ? 1.05 : 1.0)
                .shadow(color: isFocused ? .blue.opacity(0.5) : .clear, radius: 10)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

#Preview {
    VStack(spacing: 20) {
        GridButton(title: "2024", action: {})
        OptionButton(text: "United States", action: {})
    }
    .padding()
}
