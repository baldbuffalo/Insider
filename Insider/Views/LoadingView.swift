import SwiftUI

struct LoadingView: View {
    let onComplete: () -> Void

    @State private var completedSteps: Set<Int> = []
    @State private var activeStep: Int = -1
    @State private var visibleSteps: Set<Int> = []
    @State private var progress: Double = 0
    @State private var bottomText = "Getting things ready…"

    private let steps = LoadingStep.steps

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0D0D14").ignoresSafeArea()

            // Ambient glows
            GlowOrb(color: Color(hex: "5B4DFF"), size: 260, offset: CGPoint(x: -80, y: -160), opacity: 0.18, delay: 0)
            GlowOrb(color: Color(hex: "FF4D8D"), size: 200, offset: CGPoint(x: 80, y: 160),  opacity: 0.15, delay: 2)
            GlowOrb(color: Color(hex: "4DCCFF"), size: 160, offset: CGPoint(x: -60, y: 80),  opacity: 0.12, delay: 1)

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(
                                colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color(hex: "5B4DFF").opacity(0.5), radius: 20, x: 0, y: 8)

                        Text("📡")
                            .font(.system(size: 28))
                    }

                    Text("Insider")
                        .font(.custom("Helvetica Neue", size: 20))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 52)

                // Steps
                VStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        VStack(spacing: 0) {
                            StepRow(
                                step: step,
                                index: index,
                                isVisible: visibleSteps.contains(index),
                                isActive: activeStep == index,
                                isDone: completedSteps.contains(index)
                            )
                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.07))
                                    .frame(width: 1, height: 10)
                                    .padding(.leading, -120)
                            }
                        }
                    }
                }
                .padding(.horizontal, 36)

                Spacer()

                // Bottom progress
                VStack(spacing: 10) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 180, height: 3)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 180 * progress, height: 3)
                            .animation(.easeInOut(duration: 0.6), value: progress)
                    }

                    Text(bottomText)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.22))
                        .animation(.easeInOut, value: bottomText)
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear { startSequence() }
    }

    private func startSequence() {
        runStep(0)
    }

    private func runStep(_ index: Int) {
        guard index < steps.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { onComplete() }
            return
        }

        // Show step
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.4)) {
                visibleSteps.insert(index)
                activeStep = index
            }
        }

        // Complete step
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.3)) {
                completedSteps.insert(index)
                activeStep = -1
                progress = steps[index].progress
                bottomText = steps[index].completedText
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                runStep(index + 1)
            }
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

    @State private var rotation: Double = 0

    var body: some View {
        HStack(spacing: 14) {
            // Icon circle
            ZStack {
                Circle()
                    .stroke(
                        isDone
                            ? Color.clear
                            : (isActive ? Color(hex: "5B4DFF").opacity(0.6) : Color.white.opacity(0.1)),
                        lineWidth: 1.5
                    )
                    .background(
                        Circle().fill(
                            isDone
                                ? LinearGradient(colors: [Color(hex: "5B4DFF"), Color(hex: "7C6FFF")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : (isActive ? Color(hex: "5B4DFF").opacity(0.12) : Color.white.opacity(0.04))
                        )
                    )
                    .frame(width: 34, height: 34)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else if isActive {
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(Color(hex: "5B4DFF").opacity(0.8), lineWidth: 2)
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isDone)
            .animation(.easeInOut(duration: 0.3), value: isActive)

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(step.label)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundColor(isDone ? .white.opacity(0.3) : .white.opacity(0.85))

                Text(step.subtitle)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(isDone ? .white.opacity(0.15) : .white.opacity(0.3))
            }

            Spacer()
        }
        .padding(.vertical, 11)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .animation(.easeOut(duration: 0.4), value: isVisible)
    }
}

// MARK: - Glow Orb
struct GlowOrb: View {
    let color: Color
    let size: CGFloat
    let offset: CGPoint
    let opacity: Double
    let delay: Double

    @State private var breathing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .blur(radius: 80)
            .opacity(breathing ? opacity * 1.3 : opacity)
            .scaleEffect(breathing ? 1.08 : 1.0)
            .offset(x: offset.x, y: offset.y)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 4)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    breathing = true
                }
            }
            .allowsHitTesting(false)
    }
}
