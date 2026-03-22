import SwiftUI

struct HomeView: View {
    @State private var creators = Creator.sampleData
    @State private var selectedCreator: Creator?
    @State private var activeTab = 0
    @State private var insightIndex = 0

    private let tabs = ["Watching", "Discover", "Platforms"]

    var topCreator: Creator? {
        creators.max(by: { $0.videoCount < $1.videoCount })
    }

    var currentInsight: String {
        guard let top = topCreator else { return "" }
        return top.insights[insightIndex % top.insights.count].text
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "0D0D14").ignoresSafeArea()

            // Ambient glow top left
            Circle()
                .fill(Color(hex: "5B4DFF"))
                .frame(width: 280, height: 280)
                .blur(radius: 100)
                .opacity(0.12)
                .offset(x: -100, y: -300)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Header
                headerSection

                // Tabs
                tabSection

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Notification banner
                        if let top = topCreator {
                            NotificationBanner(
                                creatorName: top.name,
                                insightText: currentInsight
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                        }

                        // Section header
                        HStack {
                            Text("TOP CREATORS")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundColor(.white.opacity(0.3))
                                .kerning(1)
                            Spacer()
                            Text("\(creators.count) found")
                                .font(.system(size: 10.5, weight: .medium))
                                .foregroundColor(Color(hex: "5B4DFF").opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 10)

                        // Creator grid
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                            spacing: 10
                        ) {
                            ForEach(creators) { creator in
                                CreatorCard(creator: creator)
                                    .onTapGesture {
                                        selectedCreator = creator
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 90)
                    }
                }
            }

            // Bottom nav
            BottomNavBar(activeIndex: 0)
        }
        .sheet(item: $selectedCreator) { creator in
            CreatorDetailView(creator: creator)
        }
        .onAppear {
            startInsightRotation()
        }
    }

    // MARK: Header
    private var headerSection: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text("GOOD EVENING")
                    .font(.system(size: 10.5, weight: .regular))
                    .foregroundColor(.white.opacity(0.35))
                    .kerning(0.5)

                HStack(spacing: 0) {
                    Text("Your ")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Creators")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(Color(hex: "7C6FFF"))
                }
            }
            Spacer()
            Circle()
                .fill(LinearGradient(
                    colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 32, height: 32)
                .overlay(
                    Text("GB")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 10)
    }

    // MARK: Tabs
    private var tabSection: some View {
        HStack(spacing: 6) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button(action: { activeTab = index }) {
                    Text(tab)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(activeTab == index ? Color(hex: "A99FFF") : .white.opacity(0.35))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            activeTab == index
                                ? Color(hex: "5B4DFF").opacity(0.15)
                                : Color.clear
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    activeTab == index
                                        ? Color(hex: "5B4DFF").opacity(0.3)
                                        : Color.clear,
                                    lineWidth: 1
                                )
                        )
                        .clipShape(Capsule())
                }
                .animation(.easeInOut(duration: 0.2), value: activeTab)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 2)
    }

    private func startInsightRotation() {
        Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                insightIndex += 1
            }
        }
    }
}

// MARK: - Notification Banner
struct NotificationBanner: View {
    let creatorName: String
    let insightText: String

    var body: some View {
        HStack(spacing: 0) {
            // Accent bar
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 3)
                .clipShape(Capsule())
                .padding(.trailing, 14)

            VStack(alignment: .leading, spacing: 4) {
                Group {
                    Text("Seems like you're enjoying ")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    + Text(creatorName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "A99FFF"))
                }

                Text(insightText)
                    .font(.system(size: 11.5, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .id(insightText)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "5B4DFF").opacity(0.18),
                            Color(hex: "FF4D8D").opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "5B4DFF").opacity(0.25), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.4), value: insightText)
    }
}

// MARK: - Creator Card
struct CreatorCard: View {
    let creator: Creator
    @State private var pressed = false

    var body: some View {
        VStack(spacing: 7) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 50, height: 50)

                Text(creator.emoji)
                    .font(.system(size: 22))

                if creator.isTopPick {
                    Circle()
                        .stroke(Color(hex: "5B4DFF").opacity(0.5), lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
            }

            Text(creator.name)
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            // Platform dots
            HStack(spacing: 3) {
                ForEach(creator.platforms) { platform in
                    Circle()
                        .fill(Color(hex: platform.color))
                        .frame(width: 5, height: 5)
                }
            }

            Text(creator.subtitle)
                .font(.system(size: 9.5, weight: .light))
                .foregroundColor(.white.opacity(0.25))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    creator.isTopPick
                        ? Color(hex: "5B4DFF").opacity(0.07)
                        : Color.white.opacity(0.04)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            creator.isTopPick
                                ? Color(hex: "5B4DFF").opacity(0.3)
                                : Color.white.opacity(0.07),
                            lineWidth: 1
                        )
                )
        )
        .overlay(alignment: .topTrailing) {
            if creator.isTopPick {
                Text("★")
                    .font(.system(size: 9))
                    .foregroundColor(Color(hex: "A99FFF"))
                    .padding(8)
            }
        }
        .scaleEffect(pressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { isPressing in
            pressed = isPressing
        }, perform: {})
    }
}

// MARK: - Bottom Nav
struct BottomNavBar: View {
    let activeIndex: Int
    private let items: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("magnifyingglass", "Discover"),
        ("bell.fill", "Alerts"),
        ("gearshape.fill", "Settings")
    ]

    var body: some View {
        HStack {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Spacer()
                VStack(spacing: 3) {
                    Image(systemName: item.icon)
                        .font(.system(size: 18))
                        .foregroundColor(
                            index == activeIndex
                                ? Color(hex: "A99FFF")
                                : .white.opacity(0.3)
                        )

                    Text(item.label)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(
                            index == activeIndex
                                ? Color(hex: "A99FFF")
                                : .white.opacity(0.3)
                        )

                    if index == activeIndex {
                        Circle()
                            .fill(Color(hex: "7C6FFF"))
                            .frame(width: 4, height: 4)
                    }
                }
                Spacer()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(
            Rectangle()
                .fill(Color(hex: "0D0D14").opacity(0.95))
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 1)
                }
        )
        .ignoresSafeArea(edges: .bottom)
    }
}
