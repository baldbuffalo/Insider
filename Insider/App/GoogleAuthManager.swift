import Foundation
import WebKit

// MARK: - Google User
struct GoogleUser {
    let name: String
    let email: String
    let givenName: String
}

// MARK: - Google Auth Manager
/// Signs the user in via a WKWebView sheet so Google/YouTube session cookies land in
/// WKWebsiteDataStore.default() — the same store HistoryScraper uses.
/// This means once sign-in completes the scraper can load youtube.com/feed/history
/// with a live authenticated session, no extra cookie bridging required.
class GoogleAuthManager: NSObject, ObservableObject {

    // ── OAuth config ──────────────────────────────────────────────────────────
    // Replace with your real client ID from console.cloud.google.com if needed.
    private let clientID   = "309124691372-g536heqb04ol653m5hgfqpt4dmapd8nf.apps.googleusercontent.com"
    // Intercepted inside WKNavigationDelegate — does NOT need to be a registered URL scheme.
    private let redirectURI = "com.insider.app:/oauth2callback"
    private let scope       = "https://www.googleapis.com/auth/youtube.readonly profile email"

    // ── Published state (drives the sheet in SignInView) ─────────────────────
    @Published var showWebView = false

    // The URL loaded when the sheet opens
    private(set) var authURL: URL?

    // Stored until the OAuth callback arrives
    private var pendingCompletion: ((Result<GoogleUser, Error>) -> Void)?

    // MARK: - Public API

    func signIn(completion: @escaping (Result<GoogleUser, Error>) -> Void) {
        pendingCompletion = completion

        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id",     value: clientID),
            URLQueryItem(name: "redirect_uri",  value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope",         value: scope),
            URLQueryItem(name: "access_type",   value: "offline"),
            URLQueryItem(name: "prompt",        value: "select_account"),
        ]
        authURL = components.url

        DispatchQueue.main.async { self.showWebView = true }
    }

    /// Called by the WKNavigationDelegate when it intercepts the redirect URI.
    func handleRedirect(url: URL) {
        DispatchQueue.main.async { self.showWebView = false }

        guard let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "code" })?.value
        else {
            pendingCompletion?(.failure(AuthError.noCode))
            return
        }
        exchangeCodeForToken(code: code)
    }

    /// Called when the user taps Cancel inside the sheet.
    func cancel() {
        DispatchQueue.main.async { self.showWebView = false }
        // Don't fire the completion — SignInView's onDismiss resets the loading spinner.
    }

    // MARK: - Private helpers

    private func exchangeCodeForToken(code: String) {
        guard let url = URL(string: "https://oauth2.googleapis.com/token") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpBody = [
            "code":          code,
            "client_id":     clientID,
            "redirect_uri":  redirectURI,
            "grant_type":    "authorization_code",
        ]
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        .data(using: .utf8)

        URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
            if let error { self?.pendingCompletion?(.failure(error)); return }
            guard let data,
                  let json        = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let accessToken = json["access_token"] as? String
            else { self?.pendingCompletion?(.failure(AuthError.tokenExchange)); return }
            self?.fetchUserInfo(accessToken: accessToken)
        }.resume()
    }

    private func fetchUserInfo(accessToken: String) {
        guard let url = URL(string: "https://www.googleapis.com/oauth2/v3/userinfo") else { return }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
            if let error { self?.pendingCompletion?(.failure(error)); return }
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { self?.pendingCompletion?(.failure(AuthError.userInfo)); return }

            let user = GoogleUser(
                name:      json["name"]       as? String ?? "User",
                email:     json["email"]      as? String ?? "",
                givenName: json["given_name"] as? String ?? "User"
            )
            DispatchQueue.main.async { self?.pendingCompletion?(.success(user)) }
        }.resume()
    }

    // MARK: - Errors

    enum AuthError: LocalizedError {
        case noCode, tokenExchange, userInfo
        var errorDescription: String? {
            switch self {
            case .noCode:         return "No authorisation code received"
            case .tokenExchange:  return "Token exchange failed"
            case .userInfo:       return "Could not fetch user info"
            }
        }
    }
}
