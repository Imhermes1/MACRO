import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isOnboardingComplete: Bool
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
                        // AnimatedWelcomeLogo()
                        //     .scaleEffect(showAnimation ? 1.0 : 0.8)
                        //     .opacity(showAnimation ? 1.0 : 0.0)
                        //     .animation(.easeOut(duration: 1.2), value: showAnimation)
                        
                        // Welcome message
                        VStack(spacing: 16) {
                            Text("Welcome to")
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                .opacity(showSecondaryElements ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.8).delay(0.8), value: showSecondaryElements)
                            
                            Text("MACRO")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 0)
                                .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                .opacity(showSecondaryElements ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.8).delay(1.0), value: showSecondaryElements)
                            
                            if let firstName = getFirstName() {
                                Text("Hi \(firstName)! 👋")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                    .opacity(showSecondaryElements ? 1.0 : 0.0)
                                    .animation(.easeOut(duration: 0.8).delay(1.2), value: showSecondaryElements)
                            }
                            
                            Text("Your nutrition journey starts here")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
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
                        isOnboardingComplete = true
                    }) {
                        HStack {
                            Text("Get Started!")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.blue)
                        )
                        .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                    .opacity(showSecondaryElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(2.2), value: showSecondaryElements)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
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
        // You might want to get user details from your AuthManager's session
        return nil
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
                .foregroundColor(.black)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
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