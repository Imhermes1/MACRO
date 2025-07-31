import SwiftUI

struct UniversalBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black, 
                    Color.gray.opacity(0.7), 
                    Color.cyan.opacity(0.1), 
                    Color.gray.opacity(0.3)
                ]),
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
