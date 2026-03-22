import SwiftUI

struct RootView: View {
    @State private var isLoaded = false

    var body: some View {
        ZStack {
            if isLoaded {
                HomeView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            } else {
                LoadingView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isLoaded = true
                    }
                })
                .transition(.opacity.combined(with: .scale(scale: 1.04)))
            }
        }
        .animation(.easeInOut(duration: 0.6), value: isLoaded)
    }
}
