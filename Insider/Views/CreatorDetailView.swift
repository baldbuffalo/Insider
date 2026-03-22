import SwiftUI

struct CreatorDetailView: View {
    let creator: Creator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0D0D14").ignoresSafeArea()

            // Glow
            Circle()
                .fill(Color(hex: "5B4DFF"))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .opacity(0.12)
                .offset(x: -80, y: -250)
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 14) {
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(10)
                                    .background(Circle().fill(Color.white.opacity(0.08)))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Avatar + name
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "5B4DFF").opacity(0.1))
                                    .frame(width: 88, height: 88)

                                Text(creator.emoji)
                                    .font(.system(size: 44))

                                if creator.isTopPick {
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 96, height: 96)
                                }
                            }

                            VStack(spacing: 4) {
                                Text(creator.name)
                                    .font(.system(size: 24, weight: .heavy))
                                    .foregroundColor(.white)

                                if creator.isTopPick {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 9))
                                        Text("Your top pick")
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(Color(hex: "A99FFF"))
                                }
                            }

                            // Platform pills
                            HStack(spacing: 6) {
                                ForEach(creator.platforms) { platform in
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(Color(hex: platform.color))
                                            .frame(width: 6, height: 6)
                                        Text(platform.rawValue)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(Color.white.opacity(0.07))
                                            .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                                    )
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    // Stats row
                    HStack(spacing: 10) {
                        StatBox(value: "\(creator.videoCount)", label: "Videos Watched")
                        StatBox(value: "\(creator.platforms.count)", label: "Platforms")
                        StatBox(value: creator.isTopPick ? "#1" : "Top 6", label: "Your Rank")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)

                    // Insights
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("WHAT YOU MIGHT NOT KNOW")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundColor(.white.opacity(0.3))
                                .kerning(1)
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 8) {
                            ForEach(creator.insights) { insight in
                                InsightRow(text: insight.text)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9.5, weight: .regular))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
}

// MARK: - Insight Row
struct InsightRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(.white.opacity(0.65))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
}
