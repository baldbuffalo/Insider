import SwiftUI

struct SignInView: View {
    let onSignedIn: (GoogleUser) -> Void

    @StateObject private var authManager = GoogleAuthManager()
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showError = false

    var body: some View {
        ZStack {
            Color(hex: "0D0D14").ignoresSafeArea()

            // Ambient glows
            GlowOrb(color: Color(hex: "5B4DFF"), size: 300, offset: CGPoint(x: -80, y: -200), opacity: 0.15, delay: 0)
            GlowOrb(color: Color(hex: "FF4D8D"), size: 220, offset: CGPoint(x: 100, y: 200),  opacity: 0.12, delay: 2)

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22)
                            .fill(LinearGradient(
                                colors: [Color(hex: "5B4DFF"), Color(hex: "FF4D8D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                            .shadow(color: Color(hex: "5B4DFF").opacity(0.5), radius: 24, x: 0, y: 10)
                        Text("📡")
                            .font(.system(size: 38))
                    }

                    Text("Insider")
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundColor(.white)

                    Text("Know everything about\nthe creators you watch")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer()

                // Feature pills
                VStack(spacing: 10) {
                    FeaturePill(icon: "play.rectangle.fill", text: "Scans your YouTube watch history")
                    FeaturePill(icon: "bell.fill",           text: "Notifies you with creator insights")
                    FeaturePill(icon: "safari.fill",         text: "Discovers similar creators for you")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)

                // Sign-in button
                VStack(spacing: 14) {
                    Button(action: handleSignIn) {
                        HStack(spacing: 12) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "0D0D14")))
                                    .scaleEffect(0.85)
                                Text("Opening sign-in…")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "0D0D14"))
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 24, height: 24)
                                    Text("G")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(hex: "4285F4"))
                                }
                                Text("Continue with Google")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "0D0D14"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                                .shadow(color: .white.opacity(0.2), radius: 20, x: 0, y: 8)
                        )
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 28)

                    Text("We only read your watch history.\nYour data never leaves your device.")
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.25))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.bottom, 52)
            }
        }
        // ── Google sign-in sheet ────────────────────────────────────────────
        // Presented when authManager.showWebView flips to true.
        // onDismiss fires for both Cancel and successful completion so the
        // loading spinner is always reset if the sheet closes without a user.
        .sheet(isPresented: $authManager.showWebView, onDismiss: {
            // Only reset the spinner if we didn't successfully sign in
            // (a successful sign-in calls onSignedIn and transitions away before this fires).
            if isLoading { withAnimation { isLoading = false } }
        }) {
            GoogleSignInSheet(authManager: authManager)
        }
        .alert("Sign In Failed", isPresented: $showError) {
            Button("Try Again") { showError = false }
        } message: {
            Text(errorMessage ?? "Something went wrong. Please try again.")
        }
    }

    // MARK: - Action

    private func handleSignIn() {
        withAnimation { isLoading = true }

        authManager.signIn { result in
            switch result {
            case .success(let user):
                // Keep isLoading = true so the button stays disabled during the
                // transition animation; RootView will swap screens immediately.
                onSignedIn(user)

            case .failure(let error):
                withAnimation { isLoading = false }
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Feature Pill
struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "A99FFF"))
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.07), lineWidth: 1))
        )
    }
}
