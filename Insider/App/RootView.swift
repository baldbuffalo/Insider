import SwiftUI

// MARK: - App State
enum AppState {
    case splash     // < 1 s — checking for existing session
    case signIn
    case loading
    case main
}

// MARK: - Root View
struct RootView: View {

    @State private var appState: AppState = .splash
    @State private var signedInUser: GoogleUser? = nil
    @State private var accessToken: String? = nil
    @State private var creators: [Creator] = Creator.sampleData

    private let auth = GoogleAuthManager()

    var body: some View {
        ZStack {
            switch appState {

            case .splash:
                Color(hex: "0D0D14").ignoresSafeArea()

            case .signIn:
                SignInView(onSignedIn: { user, token in
                    SessionStore.shared.save(user: user)
                    signedInUser = user
                    accessToken  = token
                    withAnimation(.easeInOut(duration: 0.5)) { appState = .loading }
                })
                .transition(.opacity)

            case .loading:
                LoadingView(
                    user: signedInUser,
                    accessToken: accessToken,
                    onComplete: { scrapedCreators in
                        creators = scrapedCreators
                        withAnimation(.easeInOut(duration: 0.6)) { appState = .main }
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .opacity.combined(with: .scale(scale: 1.04))
                ))

            case .main:
                HomeView(
                    creators: creators,
                    onSignOut: {
                        auth.signOut()
                        SessionStore.shared.clearUser()
                        accessToken  = nil
                        signedInUser = nil
                        withAnimation(.easeInOut(duration: 0.5)) { appState = .signIn }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState)
        .onAppear { checkExistingSession() }
    }

    // MARK: - Session check on cold launch

    private func checkExistingSession() {
        auth.restorePreviousSignIn { result in
            switch result {
            case .success(let payload):
                // Returning user — skip sign-in entirely
                SessionStore.shared.save(user: payload.user)
                signedInUser = payload.user
                accessToken  = payload.accessToken
                withAnimation(.easeInOut(duration: 0.4)) { appState = .loading }

            case .failure:
                // No session or expired — show sign-in
                SessionStore.shared.clearUser()
                withAnimation(.easeInOut(duration: 0.4)) { appState = .signIn }
            }
        }
    }
}
