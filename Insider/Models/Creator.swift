import Foundation

// MARK: - Platform
enum Platform: String, CaseIterable, Identifiable {
    case youtube   = "YouTube"
    case instagram = "Instagram"
    case tiktok    = "TikTok"
    case twitter   = "Twitter"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .youtube:   return "FF4444"
        case .instagram: return "E1306C"
        case .tiktok:    return "69C9D0"
        case .twitter:   return "1DA1F2"
        }
    }

    var icon: String {
        switch self {
        case .youtube:   return "play.rectangle.fill"
        case .instagram: return "camera.fill"
        case .tiktok:    return "music.note"
        case .twitter:   return "bird.fill"
        }
    }
}

// MARK: - Creator Insight
struct CreatorInsight: Identifiable {
    let id = UUID()
    let text: String
}

// MARK: - Creator
struct Creator: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let platforms: [Platform]
    let videoCount: Int
    let isTopPick: Bool
    let insights: [CreatorInsight]

    var subtitle: String {
        "\(videoCount) videos watched"
    }
}

// MARK: - Sample Data
extension Creator {
    static let sampleData: [Creator] = [
        Creator(
            name: "KreekCraft",
            emoji: "🎮",
            platforms: [.youtube, .instagram, .tiktok],
            videoCount: 47,
            isTopPick: true,
            insights: [
                CreatorInsight(text: "Did you know he has a second channel called KreekCraft Shorts with daily content not on his main page?"),
                CreatorInsight(text: "He started making Roblox content back in 2015 and now has over 6 million subscribers."),
                CreatorInsight(text: "His real name is Preston and he's based in Florida."),
                CreatorInsight(text: "He also streams live on YouTube every week — check the Community tab for schedules.")
            ]
        ),
        Creator(
            name: "MrBeast",
            emoji: "💥",
            platforms: [.youtube, .instagram, .twitter],
            videoCount: 11,
            isTopPick: true,
            insights: [
                CreatorInsight(text: "MrBeast has 7 YouTube channels including MrBeast Gaming and Beast Reacts."),
                CreatorInsight(text: "He launched his own chocolate brand called Feastables which you can order online."),
                CreatorInsight(text: "Did you know he planted over 20 million trees through his Team Trees campaign?")
            ]
        ),
        Creator(
            name: "Unspeakable",
            emoji: "🌿",
            platforms: [.youtube],
            videoCount: 8,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "Unspeakable has a second channel called UnspeakableReacts where he reacts to other content."),
                CreatorInsight(text: "He runs a merch store at unspeakable.com that drops new items every month.")
            ]
        ),
        Creator(
            name: "Flamingo",
            emoji: "🔥",
            platforms: [.youtube, .tiktok],
            videoCount: 6,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "Flamingo's real name is Albert and he also runs the channel AlbertsStuff with older videos."),
                CreatorInsight(text: "He's known for his unscripted style — most of his videos are filmed in one take.")
            ]
        ),
        Creator(
            name: "Preston",
            emoji: "⚡",
            platforms: [.youtube, .instagram],
            videoCount: 5,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "Preston runs 5 different YouTube channels covering Minecraft, Roblox, and vlogs."),
                CreatorInsight(text: "His wife Brianna also has her own YouTube channel with over 7 million subscribers.")
            ]
        ),
        Creator(
            name: "Typical Gamer",
            emoji: "🏆",
            platforms: [.youtube, .twitter],
            videoCount: 4,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "Typical Gamer streams live on YouTube multiple times per week — usually evenings EST."),
                CreatorInsight(text: "He started with GTA videos in 2012 before expanding to Fortnite and other games.")
            ]
        )
    ]
}

// MARK: - Loading Step
struct LoadingStep: Identifiable {
    let id = UUID()
    let label: String
    let subtitle: String
    let completedText: String
    let progress: Double
}

extension LoadingStep {
    static let steps: [LoadingStep] = [
        LoadingStep(label: "Connecting to Google",   subtitle: "Verifying your account",        completedText: "Secured connection ✓",            progress: 0.25),
        LoadingStep(label: "Reading watch history",  subtitle: "Scanning your YouTube activity", completedText: "Found 847 videos watched",         progress: 0.55),
        LoadingStep(label: "Finding your creators",  subtitle: "Counting who you watch most",    completedText: "Identified 12 creators you love",  progress: 0.78),
        LoadingStep(label: "Building your profile",  subtitle: "Personalising your experience",  completedText: "All done! Opening your feed…",     progress: 1.0)
    ]
}
