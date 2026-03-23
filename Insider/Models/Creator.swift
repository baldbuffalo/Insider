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
    var videoCount: Int          // mutable so we can inject the real scraped count
    let isTopPick: Bool
    let insights: [CreatorInsight]

    var subtitle: String {
        videoCount > 0 ? "\(videoCount) videos watched" : "Suggested for you"
    }
}

// MARK: - Sample / Fallback Data
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
        LoadingStep(label: "Reading watch history",  subtitle: "Scanning your YouTube activity", completedText: "Found your watch history",         progress: 0.55),
        LoadingStep(label: "Finding your creators",  subtitle: "Counting who you watch most",    completedText: "Identified creators you love",     progress: 0.78),
        LoadingStep(label: "Building your profile",  subtitle: "Personalising your experience",  completedText: "All done! Opening your feed…",     progress: 1.0)
    ]
}

// MARK: - Suggested Creators
extension Creator {
    static let suggestedData: [Creator] = [
        Creator(
            name: "DanTDM",
            emoji: "💎",
            platforms: [.youtube, .twitter],
            videoCount: 0,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "DanTDM has over 26 million subscribers and started with Minecraft content in 2012."),
                CreatorInsight(text: "He wrote a graphic novel called 'Trayaurus and the Enchanted Crystal' which hit #1 on bestseller lists.")
            ]
        ),
        Creator(
            name: "SSundee",
            emoji: "🎲",
            platforms: [.youtube],
            videoCount: 0,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "SSundee took a break from YouTube in 2016 but came back stronger with Among Us content."),
                CreatorInsight(text: "His real name is Ian and he served in the US Air Force before becoming a YouTuber.")
            ]
        ),
        Creator(
            name: "Aphmau",
            emoji: "🌸",
            platforms: [.youtube, .instagram],
            videoCount: 0,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "Aphmau is known for her Minecraft roleplay series and has over 20 million subscribers."),
                CreatorInsight(text: "She also runs a merch line and has a second channel focused on vlogs and personal content.")
            ]
        ),
        Creator(
            name: "Popularmmos",
            emoji: "⚔️",
            platforms: [.youtube],
            videoCount: 0,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "PopularMMOs has been making Minecraft content since 2012 and has over 17 million subscribers."),
                CreatorInsight(text: "He and his former partner Pat and Jen were one of YouTube's most watched gaming duos.")
            ]
        ),
        Creator(
            name: "Sketch",
            emoji: "✏️",
            platforms: [.youtube, .tiktok],
            videoCount: 0,
            isTopPick: false,
            insights: [
                CreatorInsight(text: "Sketch is known for his Roblox content and comedy style similar to KreekCraft."),
                CreatorInsight(text: "He has a second channel called Sketch Plays where he posts shorter videos.")
            ]
        )
    ]
}

// MARK: - Known Creator Database
/// Expand this dictionary as you add more creators.
/// Keys are all the channel name variants YouTube might display (lowercased).
private let knownCreatorDB: [(aliases: [String], template: Creator)] = [
    (
        ["kreekcraft", "kreek"],
        Creator(name: "KreekCraft", emoji: "🎮", platforms: [.youtube, .instagram, .tiktok], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "He has a second channel called KreekCraft Shorts with daily content not on his main page."),
                    CreatorInsight(text: "He started making Roblox content back in 2015 and now has over 6 million subscribers."),
                    CreatorInsight(text: "His real name is Preston and he's based in Florida."),
                    CreatorInsight(text: "He streams live on YouTube every week — check the Community tab for schedules.")
                ])
    ),
    (
        ["mrbeast", "mr beast", "beast"],
        Creator(name: "MrBeast", emoji: "💥", platforms: [.youtube, .instagram, .twitter], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "MrBeast has 7 YouTube channels including MrBeast Gaming and Beast Reacts."),
                    CreatorInsight(text: "He launched his own chocolate brand called Feastables which you can order online."),
                    CreatorInsight(text: "He planted over 20 million trees through his Team Trees campaign.")
                ])
    ),
    (
        ["unspeakable", "unspeakablegaming"],
        Creator(name: "Unspeakable", emoji: "🌿", platforms: [.youtube], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Unspeakable has a second channel called UnspeakableReacts where he reacts to other content."),
                    CreatorInsight(text: "He runs a merch store at unspeakable.com that drops new items every month.")
                ])
    ),
    (
        ["flamingo", "albertsstuff"],
        Creator(name: "Flamingo", emoji: "🔥", platforms: [.youtube, .tiktok], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Flamingo's real name is Albert and he also runs the channel AlbertsStuff with older videos."),
                    CreatorInsight(text: "He's known for his unscripted style — most of his videos are filmed in one take.")
                ])
    ),
    (
        ["prestonplayz", "preston"],
        Creator(name: "Preston", emoji: "⚡", platforms: [.youtube, .instagram], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Preston runs 5 different YouTube channels covering Minecraft, Roblox, and vlogs."),
                    CreatorInsight(text: "His wife Brianna also has her own YouTube channel with over 7 million subscribers.")
                ])
    ),
    (
        ["typical gamer", "typicalgamer"],
        Creator(name: "Typical Gamer", emoji: "🏆", platforms: [.youtube, .twitter], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Typical Gamer streams live on YouTube multiple times per week — usually evenings EST."),
                    CreatorInsight(text: "He started with GTA videos in 2012 before expanding to Fortnite and other games.")
                ])
    ),
    (
        ["dantdm", "the diamond minecart"],
        Creator(name: "DanTDM", emoji: "💎", platforms: [.youtube, .twitter], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "DanTDM has over 26 million subscribers and started with Minecraft content in 2012."),
                    CreatorInsight(text: "He wrote a graphic novel 'Trayaurus and the Enchanted Crystal' which hit #1 on bestseller lists.")
                ])
    ),
    (
        ["ssundee"],
        Creator(name: "SSundee", emoji: "🎲", platforms: [.youtube], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "SSundee took a break in 2016 but came back stronger with Among Us content."),
                    CreatorInsight(text: "His real name is Ian and he served in the US Air Force before becoming a YouTuber.")
                ])
    ),
    (
        ["aphmau"],
        Creator(name: "Aphmau", emoji: "🌸", platforms: [.youtube, .instagram], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Aphmau is known for her Minecraft roleplay series and has over 20 million subscribers."),
                    CreatorInsight(text: "She also runs a merch line and has a second channel focused on vlogs and personal content.")
                ])
    ),
    (
        ["popularmmos", "popular mmos", "pat and jen"],
        Creator(name: "PopularMMOs", emoji: "⚔️", platforms: [.youtube], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "PopularMMOs has been making Minecraft content since 2012 and has over 17 million subscribers."),
                    CreatorInsight(text: "He and Pat and Jen were one of YouTube's most-watched gaming duos.")
                ])
    ),
    (
        ["sketch", "sketchyt"],
        Creator(name: "Sketch", emoji: "✏️", platforms: [.youtube, .tiktok], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Sketch is known for his Roblox content and upbeat comedy style."),
                    CreatorInsight(text: "He has a second channel called Sketch Plays where he posts shorter videos.")
                ])
    ),
    (
        ["markiplier"],
        Creator(name: "Markiplier", emoji: "🎭", platforms: [.youtube, .twitter], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Markiplier co-founded CLOAK, a clothing brand, and Scape, an audio platform."),
                    CreatorInsight(text: "He launched his own ad network called Percent and has a podcast called Distractible.")
                ])
    ),
    (
        ["jacksepticeye", "jacksepticeyesam"],
        Creator(name: "Jacksepticeye", emoji: "🍀", platforms: [.youtube, .twitter, .tiktok], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Jacksepticeye co-owns Top of the Mornin Coffee and has donated millions to charity."),
                    CreatorInsight(text: "His real name is Seán McLoughlin and he's from Ballycumber, Ireland.")
                ])
    ),
    (
        ["pewdiepie", "pewds"],
        Creator(name: "PewDiePie", emoji: "🥧", platforms: [.youtube, .twitter], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "PewDiePie held the most-subscribed YouTube channel record for years before being overtaken by MrBeast."),
                    CreatorInsight(text: "His real name is Felix Kjellberg and he moved to Japan with his wife Marzia.")
                ])
    ),
    (
        ["ninja"],
        Creator(name: "Ninja", emoji: "🥷", platforms: [.youtube, .twitter, .tiktok], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Ninja was the first gamer on the cover of ESPN Magazine."),
                    CreatorInsight(text: "He broke the record for most Twitch subscribers — over 269,000 at his peak.")
                ])
    ),
    (
        ["lankybox", "lanky box"],
        Creator(name: "LankyBox", emoji: "📦", platforms: [.youtube, .tiktok], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "LankyBox is a duo channel — Justin and Adam — who met in high school."),
                    CreatorInsight(text: "Their channel blew up with Roblox and Among Us content and they now sell plushie merch.")
                ])
    ),
    (
        ["dream", "dreamwastaken"],
        Creator(name: "Dream", emoji: "🌙", platforms: [.youtube, .twitter], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Dream's Minecraft Manhunt series is one of the most-viewed gaming series on YouTube."),
                    CreatorInsight(text: "He kept his face hidden for years, making his face reveal one of YouTube's biggest events.")
                ])
    ),
    (
        ["technoblade"],
        Creator(name: "Technoblade", emoji: "🐷", platforms: [.youtube, .twitter], videoCount: 0, isTopPick: false,
                insights: [
                    CreatorInsight(text: "Technoblade never dies — he won the Potato War event and countless Minecraft championships."),
                    CreatorInsight(text: "His final video, uploaded by his family after his passing, has over 60 million views.")
                ])
    ),
]

// MARK: - Build Creators from Scraped Data
extension Creator {

    /// Converts raw channel-name → count pairs from the web scraper into a sorted [Creator] list.
    /// - Matched channels use the rich known-creator template (with insights, platforms, emoji).
    /// - Unmatched channels get a generic Creator so real data is never thrown away.
    /// - Returns `sampleData` as a fallback when the scrape yielded nothing.
    static func buildFromScrape(_ counts: [String: Int]) -> [Creator] {
        guard !counts.isEmpty else { return sampleData }

        var result: [Creator] = []
        var usedAliases: Set<String> = []

        // ── 1. Match to known creator database ──────────────────────────────
        for entry in knownCreatorDB {
            var bestCount = 0
            var matchedOriginalName: String? = nil

            for (channelName, count) in counts {
                let lower = channelName.lowercased()
                let isMatch = entry.aliases.contains(where: { lower.contains($0) || $0.contains(lower) })
                if isMatch && count > bestCount {
                    bestCount = count
                    matchedOriginalName = channelName
                }
            }

            if bestCount > 0, let originalName = matchedOriginalName {
                usedAliases.insert(originalName.lowercased())
                var c = entry.template
                c = Creator(name: c.name, emoji: c.emoji, platforms: c.platforms,
                            videoCount: bestCount, isTopPick: false, insights: c.insights)
                result.append(c)
            }
        }

        // ── 2. Any remaining channels become generic creators ───────────────
        let genericEmojis = ["📺","🎬","✨","🌟","🎯","🔮","🎪","🚀","🌈","💫","🎧","🎵"]
        var emojiCursor = 0

        let sortedUnknown = counts
            .filter { !usedAliases.contains($0.key.lowercased()) }
            .sorted { $0.value > $1.value }

        for (channelName, count) in sortedUnknown {
            // Skip obvious noise (very short strings, numbers, etc.)
            guard channelName.count > 2, channelName.count < 80 else { continue }

            let emoji = genericEmojis[emojiCursor % genericEmojis.count]
            emojiCursor += 1

            let generic = Creator(
                name: channelName,
                emoji: emoji,
                platforms: [.youtube],
                videoCount: count,
                isTopPick: false,
                insights: [
                    CreatorInsight(text: "You've watched \(count) video\(count == 1 ? "" : "s") from this channel.")
                ]
            )
            result.append(generic)
        }

        // ── 3. Sort by video count, mark top two as picks ──────────────────
        result.sort { $0.videoCount > $1.videoCount }

        // Promote top 2 to isTopPick = true
        result = result.enumerated().map { idx, creator in
            Creator(name: creator.name, emoji: creator.emoji, platforms: creator.platforms,
                    videoCount: creator.videoCount, isTopPick: idx < 2, insights: creator.insights)
        }

        // Clamp to a sane maximum for the UI
        return Array(result.prefix(20))
    }
}
