import Foundation
import GoogleSignIn

// MARK: - Google User
struct GoogleUser {
    let name: String
    let email: String
    let givenName: String
}

// MARK: - Google Auth Manager
/// Wraps GIDSignIn so the rest of the app stays decoupled from the SDK.
/// Presents the native iOS Google account picker — no browser, no web view.
class GoogleAuthManager: NSObject, ObservableObject {

    private let clientID = "309124691372-g536heqb04ol653m5hgfqpt4dmapd8nf.apps.googleusercontent.com"

    // MARK: - Sign In

    func signIn(completion: @escaping (Result<(user: GoogleUser, accessToken: String), Error>) -> Void) {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        guard let rootVC = rootViewController else {
            completion(.failure(AuthError.noRootViewController))
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let result else {
                completion(.failure(AuthError.noResult))
                return
            }
            DispatchQueue.main.async {
                completion(.success(self.pack(result.user)))
            }
        }
    }

    // MARK: - Session Restore

    /// Silently restores a previous sign-in and refreshes the access token.
    func restorePreviousSignIn(
        completion: @escaping (Result<(user: GoogleUser, accessToken: String), Error>) -> Void
    ) {
        guard GIDSignIn.sharedInstance.hasPreviousSignIn() else {
            completion(.failure(AuthError.noExistingSession))
            return
        }

        GIDSignIn.sharedInstance.restorePreviousSignIn { gidUser, error in
            if let error { completion(.failure(error)); return }
            guard let gidUser else { completion(.failure(AuthError.noResult)); return }

            // Always refresh so HistoryScraper gets a non-expired token.
            gidUser.refreshTokensIfNeeded { refreshed, refreshError in
                if let refreshError { completion(.failure(refreshError)); return }
                DispatchQueue.main.async {
                    completion(.success(self.pack(refreshed ?? gidUser)))
                }
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    // MARK: - Helpers

    private func pack(_ gidUser: GIDGoogleUser) -> (user: GoogleUser, accessToken: String) {
        let profile = gidUser.profile
        return (
            user: GoogleUser(
                name:      profile?.name      ?? "User",
                email:     profile?.email     ?? "",
                givenName: profile?.givenName ?? "User"
            ),
            accessToken: gidUser.accessToken.tokenString
        )
    }

    private var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }

    enum AuthError: LocalizedError {
        case noRootViewController, noResult, noExistingSession
        var errorDescription: String? {
            switch self {
            case .noRootViewController: return "Could not find a window to present sign-in"
            case .noResult:             return "Sign-in returned no result"
            case .noExistingSession:    return "No previous sign-in found"
            }
        }
    }
}
