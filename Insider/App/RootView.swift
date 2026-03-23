import SwiftUI

enum AppState {
    case signIn
    case loading
    case main
}

struct RootView: View {
    @State private var appState: AppState = .signIn
    @State private var signedInUser: GoogleUser? = nil
    /// Populated by LoadingView when the scraper finishes; falls back to sample data.
    @State private var creators: [Creator] = Creator.sampleData

    var body: some View {
        ZStack {
            switch appState {
            case .signIn:
                SignInView(onSignedIn: { user in
                    signedInUser = user
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState = .loading
                    }
                })
                .transition(.opacity)

            case .loading:
                LoadingView(
                    user: signedInUser,
                    onComplete: { scrapedCreators in
                        creators = scrapedCreators
                        withAnimation(.easeInOut(duration: 0.6)) {
                            appState = .main
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .opacity.combined(with: .scale(scale: 1.04))
                ))

            case .main:
                HomeView(creators: creators)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState)
    }
}
