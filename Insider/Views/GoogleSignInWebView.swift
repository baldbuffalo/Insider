import SwiftUI
import WebKit

// MARK: - Google Sign-In Sheet
/// Presented modally from SignInView.
/// The WKWebView inside uses WKWebsiteDataStore.default() so every cookie Google
/// and YouTube set during sign-in is available to HistoryScraper automatically.
struct GoogleSignInSheet: View {
    @ObservedObject var authManager: GoogleAuthManager

    var body: some View {
        NavigationView {
            GoogleSignInWebView(authManager: authManager)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Sign in with Google")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Color(hex: "0D0D14"), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { authManager.cancel() }
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - UIViewRepresentable
private struct GoogleSignInWebView: UIViewRepresentable {
    @ObservedObject var authManager: GoogleAuthManager

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // ⚠️ Must be .default() — same store HistoryScraper uses.
        // Once the user signs in here, YouTube cookies persist and the
        // scraper can load /feed/history with a live session.
        config.websiteDataStore = .default()

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator

        // A realistic mobile Safari UA keeps Google's sign-in flow simple.
        wv.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) " +
                             "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
                             "Version/17.0 Mobile/15E148 Safari/604.1"

        if let url = authManager.authURL {
            wv.load(URLRequest(url: url))
        }
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(authManager: authManager) }

    // MARK: - Coordinator / WKNavigationDelegate
    final class Coordinator: NSObject, WKNavigationDelegate {
        private let authManager: GoogleAuthManager

        init(authManager: GoogleAuthManager) {
            self.authManager = authManager
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url,
               url.scheme == "com.insider.app" {
                // Intercept the OAuth redirect before WKWebView tries (and fails) to load it.
                authManager.handleRedirect(url: url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation _: WKNavigation!,
                     withError error: Error) {
            // Ignore "unsupported URL" errors for the custom scheme interception above.
            let nsErr = error as NSError
            guard !(nsErr.domain == "WebKitErrorDomain" && nsErr.code == 102) else { return }
            print("[GoogleSignIn] navigation error: \(error.localizedDescription)")
        }
    }
}
