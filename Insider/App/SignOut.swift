import WebKit
import SwiftUI

// MARK: - Sign Out
/// Call this from SettingsView's sign-out button.
/// Clears the WKWebsiteDataStore cookies AND the saved user from UserDefaults,
/// so the next launch hits the sign-in screen fresh.
func signOut(completion: @escaping () -> Void) {
    // 1. Clear saved user
    SessionStore.shared.clearUser()

    // 2. Wipe ALL website data from the shared store
    //    (cookies, cache, local storage — leaves no Google/YouTube session behind)
    let store = WKWebsiteDataStore.default()
    let allTypes = WKWebsiteDataStore.allWebsiteDataTypes()

    store.fetchDataRecords(ofTypes: allTypes) { records in
        store.removeData(ofTypes: allTypes, for: records) {
            DispatchQueue.main.async { completion() }
        }
    }
}
