import SwiftUI

struct LoadingView: View {
    let user: GoogleUser?
    /// Called when all loading steps finish. Passes the real scraped creators (or sample data as fallback).
    let onComplete: ([Creator]) -> Void

    @State private var completedSteps: Set<Int> = []
    @State private var activeStep: Int = -1
    @State private var visibleSteps: Set<Int> = []
    @State private var progress: Double = 0
    @State private var bottomText = "Getting things ready…"

    /// Runs concurrently with the animated steps in the background.
    @StateObject private var scraper = HistoryScraper()
    /// Stores the scrape result whenever it arrives (may be before or after steps finish).
    @State private var scrapedCounts: [String: Int]? = nil
    /// Set to true once all animated steps are done — triggers final handoff.
    @State private var stepsFinished = false

    private let steps = LoadingStep.steps

    var body: some View {
        ZStack {
            Color(hex: "0D0D14").ignoresSafeArea()

            GlowOrb(color: Color(hex: "5B4DFF"), size: 260, offset: CGPoint(x: -80, y: -160), opacity: 0.18, delay: 0)
            GlowOrb(color: Color(hex: "FF4D8D"), size: 200, offset: CGPoint(x: 80, y: 160),  opacity: 0.15, delay: 2)
            GlowOrb(color: Color(hex: "4DCCFF"), size: 160, offset: CGPoint(x: -60, y: 80),  opacity: 0.12, delay: 1)

            VStack(spacing: 0) {
                Spacer()

                // Logo + welcome
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
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)

                    if let user = user {
                        Text("Welcome, \(user.givenName)")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.bottom, 52)

                // Animated step list
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

                // Progress bar + caption
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
        .onAppear {
            // 1. Kick off the web scraper immediately in the background.
            scraper.scrape { counts in
                scrapedCounts = counts
                // If the UI steps are already done by the time this returns, hand off now.
                maybeComplete()
            }
            // 2. Start the animated step sequence.
            runStep(0)
        }
    }

    // MARK: - Step Animation

    private func runStep(_ index: Int) {
        guard index < steps.count else {
            // All steps finished — record it and try to hand off.
            stepsFinished = true
            maybeComplete()
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.4)) {
                visibleSteps.insert(index)
                activeStep = index
            }

            // Dynamic subtitle on the "watch history" step
            if index == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    updateHistorySubtitle()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeInOut(duration: 0.3)) {
                completedSteps.insert(index)
                activeStep = -1
                progress = steps[index].progress

                // Show a real count on step 1 if the scraper has already finished.
                if index == 1, let counts = scrapedCounts, !counts.isEmpty {
                    let total = counts.values.reduce(0, +)
                    bottomText = "Found \(total) videos in your history"
                } else if index == 2, let counts = scrapedCounts, !counts.isEmpty {
                    bottomText = "Identified \(counts.count) creator\(counts.count == 1 ? "" : "s") you watch"
                } else {
                    bottomText = steps[index].completedText
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                runStep(index + 1)
            }
        }
    }

    /// Briefly flashes a live count on the "Reading watch history" subtitle while the step is active.
    private func updateHistorySubtitle() {
        guard activeStep == 1 else { return }
        if let counts = scrapedCounts {
            let total = counts.values.reduce(0, +)
            bottomText = total > 0 ? "Found \(total) videos so far…" : "Scanning your history…"
        } else {
            bottomText = "Scanning your history…"
            // Poll again in 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                updateHistorySubtitle()
            }
        }
    }

    // MARK: - Handoff

    /// Fires `onComplete` once both the animated steps AND the scraper are done.
    /// If the scraper never finishes (error / not logged in), we fall back gracefully.
    private func maybeComplete() {
        guard stepsFinished else { return }

        // If scraper result already here → hand off immediately.
        if let counts = scrapedCounts {
            handOff(with: counts)
            return
        }

        // Otherwise wait up to 4 extra seconds for the scraper before giving up.
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            handOff(with: scrapedCounts ?? [:])
        }
    }

    private func handOff(with counts: [String: Int]) {
        let creators = Creator.buildFromScrape(counts)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onComplete(creators)
        }
    }
}

// MARK: - Step Row (unchanged)
struct StepRow: View {
    let step: LoadingStep
    let index: Int
    let isVisible: Bool
    let isActive: Bool
    let isDone: Bool

    @State private var rotation: Double = 0

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(
                        isDone ? Color.clear : (isActive ? Color(hex: "5B4DFF").opacity(0.6) : Color.white.opacity(0.1)),
                        lineWidth: 1.5
                    )
                    .frame(width: 34, height: 34)

                if isDone {
                    Circle()
                        .fill(LinearGradient(
                            colors: [Color(hex: "5B4DFF"), Color(hex: "7C6FFF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 34, height: 34)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else if isActive {
                    Circle()
                        .fill(Color(hex: "5B4DFF").opacity(0.12))
                        .frame(width: 34, height: 34)
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
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 34, height: 34)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isDone)
            .animation(.easeInOut(duration: 0.3), value: isActive)

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

// MARK: - Glow Orb (unchanged)
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
                ) { breathing = true }
            }
            .allowsHitTesting(false)
    }
}
