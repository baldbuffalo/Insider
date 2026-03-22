# Insider 📡

A creator companion app that learns who you watch and surfaces things you didn't know about them.

---

## What it does

- Reads your YouTube watch history after Google login
- Detects which creators you're most interested in by video count
- Shows a rotating notification banner with facts you didn't know about your top creator
- Displays a card grid of all your watched creators with cross-platform info
- Tap any creator card for a full detail screen with all their insights

---

## How to build & get the IPA

### Step 1 — Fork or push to GitHub
Push this entire folder to a **public or private** GitHub repository.

### Step 2 — Run the workflow
Go to your repo on GitHub → **Actions** tab → **Build IPA** → click **Run workflow**.

The build takes about 4–6 minutes on the free GitHub Actions macOS runner.

### Step 3 — Download the IPA
When the workflow finishes:
1. Click the completed workflow run
2. Scroll to **Artifacts**
3. Download **Insider-IPA**
4. Unzip it — you'll find `Insider.ipa` inside

---

## Installing on your iPad

The IPA produced by this workflow is **unsigned**. You have two free options to install it:

### Option A — AltStore (recommended)
1. Install [AltStore](https://altstore.io) on your Mac and iPad
2. Open AltStore on your iPad → tap **+** → select `Insider.ipa`
3. It signs and installs it using your Apple ID (free, no developer account needed)
4. Re-sign every 7 days (AltStore can do this automatically via Wi-Fi)

### Option B — Sideloadly
1. Download [Sideloadly](https://sideloadly.io) on your Mac or Windows PC
2. Connect your iPad via USB
3. Drag `Insider.ipa` into Sideloadly → enter your Apple ID → click Start
4. Trust the developer profile on your iPad under Settings → General → VPN & Device Management

---

## Project structure

```
Insider/
├── .github/
│   └── workflows/
│       └── build.yml          ← GitHub Actions CI
├── Insider/
│   ├── App/
│   │   ├── InsiderApp.swift
│   │   ├── RootView.swift
│   │   └── ColorExtension.swift
│   ├── Views/
│   │   ├── LoadingView.swift
│   │   ├── HomeView.swift
│   │   └── CreatorDetailView.swift
│   ├── Models/
│   │   └── Creator.swift
│   └── Assets.xcassets/
├── project.yml                ← XcodeGen spec (generates .xcodeproj)
└── README.md
```

---

## Requirements

- iOS / iPadOS 16.0+
- No paid Apple Developer account needed for sideloading
- GitHub free tier is enough to run the build workflow
