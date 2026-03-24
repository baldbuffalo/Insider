import SwiftUI

// MARK: - Glow Orb
struct GlowOrb: View {
    let color: Color
    let size: CGFloat
    let offset: CGPoint
    let opacity: Double
    let delay: Double

    @State private var animate = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: size * 0.38)
            .opacity(animate ? opacity : opacity * 0.6)
            .offset(x: offset.x, y: offset.y)
            .scaleEffect(animate ? 1.08 : 0.94)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) { animate = true }
            }
    }
}

// MARK: - Step Row
struct StepRow: View {
    let step: LoadingStep
    let index: Int
    let isVisible: Bool
    let isActive: Bool
    let isDone: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Icon / check
            ZStack {
                Circle()
                    .fill(isDone ? Color(hex: "5B4DFF") : Color.white.opacity(0.07))
                    .frame(width: 32, height: 32)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else if isActive {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "A99FFF")))
                        .scaleEffect(0.7)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.25))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(isDone ? step.completedText : step.label)
                    .font(.system(size: 13.5, weight: isDone ? .medium : .regular))
                    .foregroundColor(isDone ? .white : isActive ? .white : .white.opacity(0.35))
                    .animation(.easeInOut(duration: 0.3), value: isDone)

                if isActive && !isDone {
                    Text(step.subtitle)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.3))
                        .transition(.opacity)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .animation(.easeOut(duration: 0.4), value: isVisible)
    }
}
