import SwiftUI
// UniversalBackground is a local SwiftUI View

struct WelcomeView: View {
    @ObservedObject var session: SessionStore
    @State private var showAnimation = false
    @State private var showSecondaryElements = false
    
    private let profileRepo = UserProfileRepository()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                UniversalBackground()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Welcome content
                    VStack(spacing: 24) {
                        // Animated logo with enhanced glow
                        AnimatedWelcomeLogo()
                            .scaleEffect(showAnimation ? 1.0 : 0.8)
                            .opacity(showAnimation ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 1.2), value: showAnimation)
                        
                        // Welcome message
                        VStack(spacing: 16) {
                            Text("Welcome to")
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                                .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                .opacity(showSecondaryElements ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.8).delay(0.8), value: showSecondaryElements)
                            
                            Text("MACRO")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                                .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                .opacity(showSecondaryElements ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.8).delay(1.0), value: showSecondaryElements)
                            
                            if let firstName = getFirstName() {
                                Text("Hi \(firstName)! 👋")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.9))
                                    .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                    .opacity(showSecondaryElements ? 1.0 : 0.0)
                                    .animation(.easeOut(duration: 0.8).delay(1.2), value: showSecondaryElements)
                            }
                            
                            Text("Your nutrition journey starts here")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                .opacity(showSecondaryElements ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.8).delay(1.4), value: showSecondaryElements)
                        }
                        .padding(.horizontal, 40)
                        
                        // Feature highlights
                        VStack(spacing: 12) {
                            WelcomeFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track your macros", delay: 1.6)
                            WelcomeFeatureRow(icon: "target", title: "Reach your goals", delay: 1.8)
                            WelcomeFeatureRow(icon: "heart.fill", title: "Stay healthy", delay: 2.0)
                        }
                        .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                        .opacity(showSecondaryElements ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8).delay(1.6), value: showSecondaryElements)
                    }
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: {
                        // Continue to BMI calculator
                        withAnimation(.easeInOut(duration: 0.3)) {
                            session.markWelcomeScreenSeen()
                        }
                    }) {
                        HStack {
                            Text("Let's Calculate Your BMI")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white.opacity(0.25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .scaleEffect(1.0)
                        .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                    .opacity(showSecondaryElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(2.2), value: showSecondaryElements)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            // Start animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showSecondaryElements = true
            }
        }
    }
    
    private func getFirstName() -> String? {
        if let profile = profileRepo.loadProfile() {
            return profile.firstName
        }
        return session.extractUserDetails().firstName
    }
}

struct WelcomeFeatureRow: View {
    let icon: String
    let title: String
    let delay: Double
    @State private var show = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .scaleEffect(show ? 1.0 : 0.8)
        .opacity(show ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.6).delay(delay), value: show)
        .onAppear {
            show = true
        }
    }
}

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
