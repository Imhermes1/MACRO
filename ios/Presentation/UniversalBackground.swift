import SwiftUI

struct UniversalBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.3)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .background(.ultraThinMaterial)
    }
}
