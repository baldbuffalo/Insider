import SwiftUI

// MARK: - App State
enum AppState {
    case splash     // checking session — shown for < 1 second
    case signIn
    case loading
    case main
}

// MARK: - Root View
struct RootView: View {

    @State private var appState: AppState = .splash
    @State private var signedInUser: GoogleUser? = nil
    @State private var creators: [Creator] = Creator.sampleData

    var body: some View {
        ZStack {
            switch appState {

            // ── Splash: invisible, just waiting for the cookie check ──────
            case .splash:
                Color(hex: "0D0D14").ignoresSafeArea()

            // ── Sign-in ───────────────────────────────────────────────────
            case .signIn:
                SignInView(onSignedIn: { user in
                    // Persist user so we can skip sign-in next launch
                    SessionStore.shared.save(user: user)
                    signedInUser = user
                    withAnimation(.easeInOut(duration: 0.5)) { appState = .loading }
                })
                .transition(.opacity)

            // ── Loading / scraping ────────────────────────────────────────
            case .loading:
                LoadingView(
                    user: signedInUser,
                    onComplete: { scrapedCreators in
                        creators = scrapedCreators
                        withAnimation(.easeInOut(duration: 0.6)) { appState = .main }
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .opacity.combined(with: .scale(scale: 1.04))
                ))

            // ── Main app ──────────────────────────────────────────────────
            case .main:
                HomeView(creators: creators)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState)
        .onAppear { checkExistingSession() }
    }

    // MARK: - Session check

    /// On every cold launch:
    /// 1. Check WKWebsiteDataStore.default() for a live Google/YouTube cookie.
    /// 2a. Cookie found + saved user → skip straight to .loading.
    /// 2b. Anything else → show .signIn.
    ///
    /// The check is fast (< 200 ms) so the splash flash is imperceptible.
    private func checkExistingSession() {
        SessionStore.shared.hasLiveSession { isAuthenticated in
            if isAuthenticated, let user = SessionStore.shared.savedUser {
                // Returning user — bypass sign-in entirely
                signedInUser = user
                withAnimation(.easeInOut(duration: 0.4)) { appState = .loading }
            } else {
                // New user or session expired
                SessionStore.shared.clearUser()
                withAnimation(.easeInOut(duration: 0.4)) { appState = .signIn }
            }
        }
    }
}
