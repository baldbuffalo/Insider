import SwiftUI
import GoogleSignIn

@main
struct InsiderApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                // GIDSignIn needs this to handle the OAuth callback URL
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
