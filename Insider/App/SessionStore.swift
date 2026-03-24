import Foundation
import WebKit

// MARK: - Session Store
/// Persists the signed-in user across app launches and detects whether
/// a live Google session already exists in WKWebsiteDataStore.default().
final class SessionStore {

    static let shared = SessionStore()
    private init() {}

    // MARK: - User persistence (UserDefaults)

    private enum Keys {
        static let name      = "insider.user.name"
        static let email     = "insider.user.email"
        static let givenName = "insider.user.givenName"
    }

    /// Saves the signed-in user so it survives app restarts.
    func save(user: GoogleUser) {
        UserDefaults.standard.set(user.name,      forKey: Keys.name)
        UserDefaults.standard.set(user.email,     forKey: Keys.email)
        UserDefaults.standard.set(user.givenName, forKey: Keys.givenName)
    }

    /// Returns the previously saved user, or nil if none exists.
    var savedUser: GoogleUser? {
        guard let name      = UserDefaults.standard.string(forKey: Keys.name),
              let email     = UserDefaults.standard.string(forKey: Keys.email),
              let givenName = UserDefaults.standard.string(forKey: Keys.givenName)
        else { return nil }
        return GoogleUser(name: name, email: email, givenName: givenName)
    }

    /// Clears the saved user (call on sign-out).
    func clearUser() {
        UserDefaults.standard.removeObject(forKey: Keys.name)
        UserDefaults.standard.removeObject(forKey: Keys.email)
        UserDefaults.standard.removeObject(forKey: Keys.givenName)
    }

    // MARK: - Cookie check

    /// Returns true if WKWebsiteDataStore.default() contains a Google
    /// or YouTube session cookie, meaning the scraper can run immediately
    /// without asking the user to sign in again.
    ///
    /// The async callback is always delivered on the main queue.
    func hasLiveSession(completion: @escaping (Bool) -> Void) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            let authenticated = cookies.contains { cookie in
                // Google identity cookies that survive across sessions
                let googleDomains  = ["google.com", "accounts.google.com", "youtube.com"]
                let sessionCookies = ["SID", "HSID", "SSID", "APISID", "SAPISID",
                                      "__Secure-1PSID", "__Secure-3PSID",
                                      "LOGIN_INFO",   // YouTube-specific session marker
                                      "CONSENT"]
                let domainMatch  = googleDomains.contains { cookie.domain.hasSuffix($0) }
                let cookieMatch  = sessionCookies.contains(cookie.name)
                return domainMatch && cookieMatch
            }
            DispatchQueue.main.async { completion(authenticated) }
        }
    }
}
