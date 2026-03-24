import Foundation

// MARK: - Session Store
/// Stores the signed-in user's display info across app launches.
/// Actual session persistence (tokens, Keychain) is handled automatically by GIDSignIn.
final class SessionStore {

    static let shared = SessionStore()
    private init() {}

    private enum Keys {
        static let name      = "insider.user.name"
        static let email     = "insider.user.email"
        static let givenName = "insider.user.givenName"
    }

    func save(user: GoogleUser) {
        UserDefaults.standard.set(user.name,      forKey: Keys.name)
        UserDefaults.standard.set(user.email,     forKey: Keys.email)
        UserDefaults.standard.set(user.givenName, forKey: Keys.givenName)
    }

    var savedUser: GoogleUser? {
        guard let name      = UserDefaults.standard.string(forKey: Keys.name),
              let email     = UserDefaults.standard.string(forKey: Keys.email),
              let givenName = UserDefaults.standard.string(forKey: Keys.givenName)
        else { return nil }
        return GoogleUser(name: name, email: email, givenName: givenName)
    }

    func clearUser() {
        UserDefaults.standard.removeObject(forKey: Keys.name)
        UserDefaults.standard.removeObject(forKey: Keys.email)
        UserDefaults.standard.removeObject(forKey: Keys.givenName)
    }
}
