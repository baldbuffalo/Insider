import SwiftUI

// MARK: - App Tab
enum AppTab {
case home, discover, alerts, settings
}

// MARK: - Home View
struct HomeView: View {
@State private var creators = Creator.sampleData
@State private var selectedCreator: Creator?
@State private var activeTab: AppTab = .home
@State private var watchingTab = 0
@State private var insightIndex = 0
@State private var searchText = ""
@State private var showSearch = false

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

        Circle()
            .fill(Color(hex: "5B4DFF"))
            .frame(width: 280, height: 280)
            .blur(radius: 100)
            .opacity(0.12)
            .offset(x: -100, y: -300)
            .allowsHitTesting(false)

        VStack(spacing: 0) {
            switch activeTab {
            case .home:     watchingScreen
            case .discover: DiscoverView(onSelect: { selectedCreator = $0 })
            case .alerts:   AlertsView(topCreator: topCreator, insight: currentInsight)
            case .settings: SettingsView()
            }
        }

        BottomNavBar(activeTab: $activeTab)
    }
    .sheet(item: $selectedCreator) { creator in
        CreatorDetailView(creator: creator)
    }
    .onAppear { startInsightRotation() }
}

// MARK: - Watching Screen
private var watchingScreen: some View {
    VStack(spacing: 0) {
        // Header
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
            Button(action: { withAnimation { showSearch.toggle() } }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.07)))
            }
            Circle()
                .fill(LinearGradient(colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 32, height: 32)
                .overlay(Text("GB").font(.system(size: 12, weight: .bold)).foregroundColor(.white))
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 10)

        // Search bar
        if showSearch {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.3))
                    .font(.system(size: 13))
                TextField("Search creators...", text: $searchText)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                    .accentColor(Color(hex: "7C6FFF"))
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.07)))
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }

        // Sub tabs
        HStack(spacing: 6) {
            ForEach(Array(["Watching", "Discover", "Platforms"].enumerated()), id: \.offset) { index, tab in
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { watchingTab = index } }) {
                    Text(tab)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(watchingTab == index ? Color(hex: "A99FFF") : .white.opacity(0.35))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(watchingTab == index ? Color(hex: "5B4DFF").opacity(0.15) : Color.clear)
                        .overlay(Capsule().stroke(watchingTab == index ? Color(hex: "5B4DFF").opacity(0.3) : Color.clear, lineWidth: 1))
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)

        // Tab content
        switch watchingTab {
        case 0: creatorGrid
        case 1: DiscoverView(onSelect: { selectedCreator = $0 })
        case 2: PlatformsView(creators: creators, onSelect: { selectedCreator = $0 })
        default: creatorGrid
        }
    }
}

// MARK: - Creator Grid
private var creatorGrid: some View {
    ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
            if let top = topCreator {
                NotificationBanner(creatorName: top.name, insightText: currentInsight)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
            }

            HStack {
                Text("TOP CREATORS")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
                    .kerning(1)
                Spacer()
                Text("\(filteredCreators.count) found")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(Color(hex: "5B4DFF").opacity(0.8))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 10)

            if filteredCreators.isEmpty {
                VStack(spacing: 12) {
                    Text("🔍")
                        .font(.system(size: 36))
                    Text("No creators found")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(filteredCreators) { creator in
                        CreatorCard(creator: creator)
                            .onTapGesture { selectedCreator = creator }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 90)
            }
        }
    }
}

private var filteredCreators: [Creator] {
    if searchText.isEmpty { return creators }
    return creators.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
}

private func startInsightRotation() {
    Timer.scheduledTimer(withTimeInterval: 12, repeats: true) { _ in
        withAnimation(.easeInOut(duration: 0.4)) { insightIndex += 1 }
    }
}

}

// MARK: - Notification Banner
struct NotificationBanner: View {
let creatorName: String
let insightText: String

var body: some View {
    HStack(spacing: 0) {
        Rectangle()
            .fill(LinearGradient(colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")], startPoint: .top, endPoint: .bottom))
            .frame(width: 3)
            .clipShape(Capsule())
            .padding(.trailing, 14)

        VStack(alignment: .leading, spacing: 4) {
            Text("Seems like you're enjoying \(creatorName)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)

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
            .fill(LinearGradient(colors: [Color(hex: "5B4DFF").opacity(0.18), Color(hex: "FF4D8D").opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color(hex: "5B4DFF").opacity(0.25), lineWidth: 1))
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
        ZStack {
            Circle().fill(Color.white.opacity(0.05)).frame(width: 50, height: 50)
            Text(creator.emoji).font(.system(size: 22))
            if creator.isTopPick {
                Circle().stroke(Color(hex: "5B4DFF").opacity(0.5), lineWidth: 2).frame(width: 56, height: 56)
            }
        }

        Text(creator.name)
            .font(.system(size: 10.5, weight: .semibold))
            .foregroundColor(.white.opacity(0.85))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)

        HStack(spacing: 3) {
            ForEach(creator.platforms) { platform in
                Circle().fill(Color(hex: platform.color)).frame(width: 5, height: 5)
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
            .fill(creator.isTopPick ? Color(hex: "5B4DFF").opacity(0.07) : Color.white.opacity(0.04))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(creator.isTopPick ? Color(hex: "5B4DFF").opacity(0.3) : Color.white.opacity(0.07), lineWidth: 1))
    )
    .overlay(alignment: .topTrailing) {
        if creator.isTopPick {
            Text("★").font(.system(size: 9)).foregroundColor(Color(hex: "A99FFF")).padding(8)
        }
    }
    .scaleEffect(pressed ? 0.95 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressed)
    .onLongPressGesture(minimumDuration: 0, pressing: { isPressing in pressed = isPressing }, perform: {})
}

}

// MARK: - Discover View
struct DiscoverView: View {
let onSelect: (Creator) -> Void
private let suggested = Creator.suggestedData

var body: some View {
    ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("BASED ON YOUR WATCHING")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                        .kerning(1)
                    Text("You might like")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)

            VStack(spacing: 10) {
                ForEach(suggested) { creator in
                    DiscoverRow(creator: creator)
                        .onTapGesture { onSelect(creator) }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 90)
        }
    }
}

}

struct DiscoverRow: View {
let creator: Creator
@State private var pressed = false

var body: some View {
    HStack(spacing: 14) {
        ZStack {
            Circle().fill(Color.white.opacity(0.06)).frame(width: 52, height: 52)
            Text(creator.emoji).font(.system(size: 24))
        }

        VStack(alignment: .leading, spacing: 4) {
            Text(creator.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            HStack(spacing: 5) {
                ForEach(creator.platforms) { platform in
                    HStack(spacing: 3) {
                        Circle().fill(Color(hex: platform.color)).frame(width: 5, height: 5)
                        Text(platform.rawValue)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 3) {
            Text("Similar to")
                .font(.system(size: 9.5))
                .foregroundColor(.white.opacity(0.3))
            Text("KreekCraft")
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(Color(hex: "A99FFF"))
        }

        Image(systemName: "chevron.right")
            .font(.system(size: 11))
            .foregroundColor(.white.opacity(0.2))
    }
    .padding(14)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.04))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.07), lineWidth: 1))
    )
    .scaleEffect(pressed ? 0.98 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressed)
    .onLongPressGesture(minimumDuration: 0, pressing: { isPressing in pressed = isPressing }, perform: {})
}

}

// MARK: - Platforms View
struct PlatformsView: View {
let creators: [Creator]
let onSelect: (Creator) -> Void
@State private var selectedPlatform: Platform = .youtube

var filteredCreators: [Creator] {
    creators.filter { $0.platforms.contains(selectedPlatform) }
}

var body: some View {
    VStack(spacing: 0) {
        // Platform picker
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Platform.allCases) { platform in
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedPlatform = platform } }) {
                        HStack(spacing: 6) {
                            Circle().fill(Color(hex: platform.color)).frame(width: 7, height: 7)
                            Text(platform.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(selectedPlatform == platform ? .white : .white.opacity(0.4))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedPlatform == platform
                                ? Color(hex: platform.color).opacity(0.2)
                                : Color.white.opacity(0.05)
                        )
                        .overlay(
                            Capsule().stroke(selectedPlatform == platform ? Color(hex: platform.color).opacity(0.5) : Color.clear, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }

        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                if filteredCreators.isEmpty {
                    VStack(spacing: 12) {
                        Text("😶")
                            .font(.system(size: 36))
                        Text("No creators on \(selectedPlatform.rawValue)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(filteredCreators) { creator in
                        DiscoverRow(creator: creator)
                            .onTapGesture { onSelect(creator) }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 90)
        }
    }
}

}

// MARK: - Alerts View
struct AlertsView: View {
let topCreator: Creator?
let insight: String

private let mockAlerts: [(emoji: String, title: String, body: String, time: String)] = [
    ("🎮", "Seems like you're enjoying KreekCraft", "Did you know he has a second channel called KreekCraft Shorts?", "2m ago"),
    ("💥", "MrBeast posted a new video", "Check out his latest challenge — already at 10M views.", "1h ago"),
    ("🌿", "New from Unspeakable", "He just dropped a Minecraft series on his second channel.", "3h ago"),
    ("🔥", "Flamingo went live", "He streamed for 4 hours yesterday — replay is up now.", "Yesterday"),
]

var body: some View {
    ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("RECENT")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                        .kerning(1)
                    Text("Alerts")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("\(mockAlerts.count) new")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "A99FFF"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color(hex: "5B4DFF").opacity(0.15)))
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 16)

            VStack(spacing: 8) {
                ForEach(Array(mockAlerts.enumerated()), id: \.offset) { index, alert in
                    AlertRow(emoji: alert.emoji, title: alert.title, message: alert.body, time: alert.time, isNew: index < 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 90)
        }
    }
}

}

struct AlertRow: View {
let emoji: String
let title: String
let message: String
let time: String
let isNew: Bool

var body: some View {
    HStack(alignment: .top, spacing: 12) {
        ZStack {
            Circle().fill(Color.white.opacity(0.06)).frame(width: 44, height: 44)
            Text(emoji).font(.system(size: 20))
            if isNew {
                Circle()
                    .fill(Color(hex: "5B4DFF"))
                    .frame(width: 8, height: 8)
                    .offset(x: 16, y: -16)
            }
        }

        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: isNew ? .semibold : .regular))
                .foregroundColor(isNew ? .white : .white.opacity(0.6))
                .lineLimit(2)
            Text(message)
                .font(.system(size: 11.5, weight: .light))
                .foregroundColor(.white.opacity(0.4))
                .lineLimit(2)
        }

        Spacer()

        Text(time)
            .font(.system(size: 10))
            .foregroundColor(.white.opacity(0.25))
    }
    .padding(14)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(isNew ? Color(hex: "5B4DFF").opacity(0.07) : Color.white.opacity(0.03))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isNew ? Color(hex: "5B4DFF").opacity(0.2) : Color.white.opacity(0.05), lineWidth: 1))
    )
}

}

// MARK: - Settings View
struct SettingsView: View {
@State private var notificationsOn = true
@State private var autoScanOn = true
@State private var showOnboarding = false

var body: some View {
    ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 24)

            // Profile card
            HStack(spacing: 14) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                    .overlay(Text("GB").font(.system(size: 18, weight: .bold)).foregroundColor(.white))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Game Buster")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Free Account")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.2))
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1)))
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            // Settings sections
            VStack(spacing: 6) {
                SettingsHeader(title: "NOTIFICATIONS")
                SettingsToggle(icon: "bell.fill", iconColor: "FF4D8D", title: "Push Notifications", subtitle: "Get alerted about new creator info", isOn: $notificationsOn)
                SettingsToggle(icon: "arrow.clockwise", iconColor: "5B4DFF", title: "Auto Scan History", subtitle: "Check YouTube history on app open", isOn: $autoScanOn)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            VStack(spacing: 6) {
                SettingsHeader(title: "CONNECTED ACCOUNTS")
                SettingsRow(icon: "play.rectangle.fill", iconColor: "FF4444", title: "YouTube", subtitle: "Connected", hasChevron: true)
                SettingsRow(icon: "camera.fill", iconColor: "E1306C", title: "Instagram", subtitle: "Not connected", hasChevron: true)
                SettingsRow(icon: "music.note", iconColor: "69C9D0", title: "TikTok", subtitle: "Not connected", hasChevron: true)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            VStack(spacing: 6) {
                SettingsHeader(title: "APP")
                SettingsRow(icon: "info.circle.fill", iconColor: "5B4DFF", title: "About Insider", subtitle: "Version 1.0.0", hasChevron: false)
                SettingsRow(icon: "hand.raised.fill", iconColor: "FF9500", title: "Privacy Policy", subtitle: "", hasChevron: true)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 90)
        }
    }
}

}

struct SettingsHeader: View {
let title: String
var body: some View {
HStack {
Text(title)
.font(.system(size: 10.5, weight: .semibold))
.foregroundColor(.white.opacity(0.3))
.kerning(1)
Spacer()
}
.padding(.bottom, 6)
.padding(.top, 4)
}
}

struct SettingsToggle: View {
let icon: String
let iconColor: String
let title: String
let subtitle: String
@Binding var isOn: Bool

var body: some View {
    HStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: iconColor).opacity(0.2))
            .frame(width: 34, height: 34)
            .overlay(Image(systemName: icon).font(.system(size: 14)).foregroundColor(Color(hex: iconColor)))

        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 13.5, weight: .medium)).foregroundColor(.white)
            Text(subtitle).font(.system(size: 11, weight: .light)).foregroundColor(.white.opacity(0.35))
        }
        Spacer()
        Toggle("", isOn: $isOn)
            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "5B4DFF")))
            .labelsHidden()
    }
    .padding(14)
    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.04)).overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 1)))
}

}

struct SettingsRow: View {
let icon: String
let iconColor: String
let title: String
let subtitle: String
let hasChevron: Bool

var body: some View {
    HStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: iconColor).opacity(0.2))
            .frame(width: 34, height: 34)
            .overlay(Image(systemName: icon).font(.system(size: 14)).foregroundColor(Color(hex: iconColor)))

        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(size: 13.5, weight: .medium)).foregroundColor(.white)
            if !subtitle.isEmpty {
                Text(subtitle).font(.system(size: 11, weight: .light)).foregroundColor(.white.opacity(0.35))
            }
        }
        Spacer()
        if hasChevron {
            Image(systemName: "chevron.right").font(.system(size: 11)).foregroundColor(.white.opacity(0.2))
        }
    }
    .padding(14)
    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.04)).overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 1)))
}

}

// MARK: - Bottom Nav Bar
struct BottomNavBar: View {
@Binding var activeTab: AppTab

private let items: [(icon: String, label: String, tab: AppTab)] = [
    ("house.fill", "Home", .home),
    ("safari.fill", "Discover", .discover),
    ("bell.fill", "Alerts", .alerts),
    ("gearshape.fill", "Settings", .settings)
]

var body: some View {
    HStack {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
            Spacer()
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { activeTab = item.tab } }) {
                VStack(spacing: 3) {
                    Image(systemName: item.icon)
                        .font(.system(size: 18))
                        .foregroundColor(activeTab == item.tab ? Color(hex: "A99FFF") : .white.opacity(0.3))
                    Text(item.label)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(activeTab == item.tab ? Color(hex: "A99FFF") : .white.opacity(0.3))
                    if activeTab == item.tab {
                        Circle().fill(Color(hex: "7C6FFF")).frame(width: 4, height: 4)
                    }
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
                Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
            }
    )
    .ignoresSafeArea(edges: .bottom)
}

}
