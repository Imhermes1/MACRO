import SwiftUI

struct UniversalBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7), Color.green.opacity(0.5)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glass effect overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}
