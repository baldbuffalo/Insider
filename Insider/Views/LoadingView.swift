import SwiftUI

struct LoadingView: View {
    let user: GoogleUser?
    let accessToken: String?          // OAuth token from GIDSignIn — passed to scraper
    let onComplete: ([Creator]) -> Void

    @State private var completedSteps: Set<Int> = []
    @State private var activeStep: Int = -1
    @State private var visibleSteps: Set<Int> = []
    @State private var progress: Double = 0
    @State private var bottomText = "Getting things ready…"

    @StateObject private var scraper = HistoryScraper()
    @State private var scrapedCounts: [String: Int]? = nil
    @State private var stepsFinished = false

    private let steps = LoadingStep.steps

    var body: some View {
        ZStack {
            Color(hex: "0D0D14").ignoresSafeArea()

            GlowOrb(color: Color(hex: "5B4DFF"), size: 260, offset: CGPoint(x: -80, y: -160), opacity: 0.18, delay: 0)
            GlowOrb(color: Color(hex: "FF4D8D"), size: 200, offset: CGPoint(x: 80, y: 160),   opacity: 0.15, delay: 2)
            GlowOrb(color: Color(hex: "4DCCFF"), size: 160, offset: CGPoint(x: -60, y: 80),   opacity: 0.12, delay: 1)

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
                        Text("📡").font(.system(size: 28))
                    }

                    Text("Insider")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)

                    if let user {
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
                        Capsule().fill(Color.white.opacity(0.06)).frame(width: 180, height: 3)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")],
                                startPoint: .leading, endPoint: .trailing
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
            // Pass the OAuth token so the scraper can establish a YouTube session
            scraper.scrape(accessToken: accessToken) { counts in
                scrapedCounts = counts
                maybeComplete()
            }
            runStep(0)
        }
    }

    // MARK: - Step Animation

    private func runStep(_ index: Int) {
        guard index < steps.count else {
            stepsFinished = true
            maybeComplete()
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.4)) {
                visibleSteps.insert(index)
                activeStep = index
            }
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

    private func updateHistorySubtitle() {
        guard activeStep == 1 else { return }
        if let counts = scrapedCounts {
            let total = counts.values.reduce(0, +)
            bottomText = total > 0 ? "Found \(total) videos so far…" : "Scanning your history…"
        } else {
            bottomText = "Scanning your history…"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { updateHistorySubtitle() }
        }
    }

    // MARK: - Handoff

    private func maybeComplete() {
        guard stepsFinished else { return }

        if let counts = scrapedCounts {
            handOff(with: counts)
            return
        }

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
