import SwiftUI

struct UniversalBackground: View {
    var body: some View {
        ZStack {
            // Base gradient - health & fitness inspired
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),  // Deep space blue
                    Color(red: 0.1, green: 0.15, blue: 0.25),   // Midnight blue
                    Color(red: 0.15, green: 0.25, blue: 0.35),  // Steel blue
                    Color(red: 0.05, green: 0.2, blue: 0.15)    // Deep forest
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated energy waves
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.cyan.opacity(0.3),
                    Color.mint.opacity(0.2),
                    Color.clear
                ]),
                center: .topTrailing,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.25),
                    Color.teal.opacity(0.15),
                    Color.clear
                ]),
                center: .bottomLeading,
                startRadius: 80,
                endRadius: 350
            )
            .ignoresSafeArea()
            
            // Futuristic grid overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .opacity(0.6)
            
            // Subtle particle effect
            Circle()
                .fill(Color.cyan.opacity(0.1))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: 100, y: -200)
            
            Circle()
                .fill(Color.mint.opacity(0.08))
                .frame(width: 150, height: 150)
                .blur(radius: 30)
                .offset(x: -120, y: 250)
        }
    }
}
