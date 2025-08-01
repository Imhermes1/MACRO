import SwiftUI

struct AnimatedWelcomeLogo: View {
    @State private var glow = false
    @State private var pulse = false
    @State private var sparkle = false
    
    var body: some View {
        ZStack {
            // Outer magical aura
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.yellow.opacity(glow ? 0.3 : 0.1),
                            Color.white.opacity(glow ? 0.2 : 0.05),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 8,
                        endRadius: glow ? 160 : 100
                    )
                )
                .frame(width: glow ? 320 : 240, height: glow ? 320 : 240)
                .blur(radius: 15)
                .scaleEffect(pulse ? 1.1 : 0.9)
            
            // Main logo with enhanced shadows
            Image("LumoraLabsLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                // Multiple layered shadows for depth
                .shadow(color: glow ? Color.yellow.opacity(0.9) : Color.white.opacity(0.7), radius: glow ? 80 : 40, x: 0, y: 0)
                .shadow(color: glow ? Color.white.opacity(0.8) : Color.yellow.opacity(0.6), radius: glow ? 50 : 25, x: 0, y: 0)
                .shadow(color: glow ? Color.yellow.opacity(0.7) : Color.white.opacity(0.5), radius: glow ? 25 : 12, x: 0, y: 0)
                .shadow(color: glow ? Color.white.opacity(0.6) : Color.yellow.opacity(0.3), radius: glow ? 12 : 6, x: 0, y: 0)
                // Subtle sparkle effect
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow.opacity(sparkle ? 0.7 : 0.2),
                                    Color.white.opacity(sparkle ? 0.5 : 0.1),
                                    Color.yellow.opacity(sparkle ? 0.3 : 0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: sparkle ? 2.5 : 1
                        )
                        .frame(width: 210, height: 210)
                        .blur(radius: 1.5)
                )
                .scaleEffect(pulse ? 1.05 : 1.0)
        }
        .onAppear {
            // Primary glow animation
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glow = true
            }
            // Secondary pulse animation
            withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
            // Sparkle animation
            withAnimation(Animation.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                sparkle = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        AnimatedWelcomeLogo()
    }
}
