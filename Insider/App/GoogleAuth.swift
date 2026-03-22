import Foundation
import AuthenticationServices

// MARK: - Google User
struct GoogleUser {
let name: String
let email: String
let givenName: String
}

// MARK: - Google Auth Manager
class GoogleAuthManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

// ⚠️ Replace this with your real Google OAuth Client ID from console.cloud.google.com
// Steps: Create project → Enable YouTube Data API v3 → Create OAuth 2.0 credentials → iOS app
  
private let clientID = "309124691372-g536heqb04ol653m5hgfqpt4dmapd8nf.apps.googleusercontent.com"

// This must match the URL scheme you add to project.yml and Google Console
// Format: com.googleusercontent.apps.YOUR_CLIENT_ID (reversed client ID)
private let redirectURI = "com.insider.app:/oauth2callback"

private let scope = "https://www.googleapis.com/auth/youtube.readonly profile email"

var authSession: ASWebAuthenticationSession?

func signIn(completion: @escaping (Result<GoogleUser, Error>) -> Void) {

    // If no real client ID set, return a demo user for testing
    if clientID.hasPrefix("YOUR_") {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(.success(GoogleUser(name: "Game Buster", email: "gamebuster@gmail.com", givenName: "Game")))
        }
        return
    }

    var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
    components.queryItems = [
        URLQueryItem(name: "client_id",     value: clientID),
        URLQueryItem(name: "redirect_uri",  value: redirectURI),
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope",         value: scope),
        URLQueryItem(name: "access_type",   value: "offline"),
        URLQueryItem(name: "prompt",        value: "select_account"),
    ]

    guard let authURL = components.url else {
        completion(.failure(AuthError.invalidURL))
        return
    }

    authSession = ASWebAuthenticationSession(
        url: authURL,
        callbackURLScheme: "com.insider.app"
    ) { callbackURL, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let callbackURL = callbackURL,
              let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "code" })?.value
        else {
            completion(.failure(AuthError.noCode))
            return
        }
        self.exchangeCodeForToken(code: code, completion: completion)
    }

    authSession?.presentationContextProvider = self
    authSession?.prefersEphemeralWebBrowserSession = false
    authSession?.start()
}

private func exchangeCodeForToken(code: String, completion: @escaping (Result<GoogleUser, Error>) -> Void) {
    guard let tokenURL = URL(string: "https://oauth2.googleapis.com/token") else { return }

    var request = URLRequest(url: tokenURL)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let body = [
        "code":          code,
        "client_id":     clientID,
        "redirect_uri":  redirectURI,
        "grant_type":    "authorization_code"
    ]
    .map { "\($0.key)=\($0.value)" }
    .joined(separator: "&")

    request.httpBody = body.data(using: .utf8)

    URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error { completion(.failure(error)); return }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let accessToken = json["access_token"] as? String
        else {
            completion(.failure(AuthError.tokenExchange))
            return
        }
        self.fetchUserInfo(accessToken: accessToken, completion: completion)
    }.resume()
}

private func fetchUserInfo(accessToken: String, completion: @escaping (Result<GoogleUser, Error>) -> Void) {
    guard let url = URL(string: "https://www.googleapis.com/oauth2/v3/userinfo") else { return }

    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error { completion(.failure(error)); return }
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            completion(.failure(AuthError.userInfo))
            return
        }
        let user = GoogleUser(
            name:      json["name"]       as? String ?? "User",
            email:     json["email"]      as? String ?? "",
            givenName: json["given_name"] as? String ?? "User"
        )
        DispatchQueue.main.async { completion(.success(user)) }
    }.resume()
}

// ASWebAuthenticationPresentationContextProviding
func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow } ?? ASPresentationAnchor()
}

enum AuthError: LocalizedError {
    case invalidURL, noCode, tokenExchange, userInfo
    var errorDescription: String? {
        switch self {
        case .invalidURL:     return "Invalid auth URL"
        case .noCode:         return "No auth code received"
        case .tokenExchange:  return "Token exchange failed"
        case .userInfo:       return "Could not fetch user info"
        }
    }
}

}
