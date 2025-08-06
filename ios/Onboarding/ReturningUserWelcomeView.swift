import SwiftUI

struct ReturningUserWelcomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var shouldShowReturningUserWelcome: Bool
    @State private var showAnimation = false
    @State private var showSecondaryElements = false
    @State private var daysSinceLastVisit: Int = 0
    
    private let profileRepo = UserProfileRepository()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                UniversalBackground()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Welcome back content
                    VStack(spacing: 24) {
                        // Welcome back message
                        VStack(spacing: 16) {
                            Text("Welcome Back!")
                                .font(.system(size: 36, weight: .thin))
                                .foregroundColor(.white)
                                .tracking(4)
                                .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 0)
                                .scaleEffect(showAnimation ? 1.0 : 0.8)
                                .opacity(showAnimation ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 1.2), value: showAnimation)
                            
                            if let firstName = getFirstName() {
                                Text("Hi \(firstName)! 👋")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                    .opacity(showSecondaryElements ? 1.0 : 0.0)
                                    .animation(.easeOut(duration: 0.8).delay(0.8), value: showSecondaryElements)
                            }
                            
                            if daysSinceLastVisit > 0 {
                                Text("It's been \(daysSinceLastVisit) day\(daysSinceLastVisit == 1 ? "" : "s") since your last visit")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                    .opacity(showSecondaryElements ? 1.0 : 0.0)
                                    .animation(.easeOut(duration: 0.8).delay(1.0), value: showSecondaryElements)
                            }
                            
                            Text("Ready to continue your nutrition journey?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                                .opacity(showSecondaryElements ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.8).delay(1.2), value: showSecondaryElements)
                        }
                        .padding(.horizontal, 40)
                        
                        // Motivational features reminder
                        VStack(spacing: 12) {
                            ReturningUserFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track your progress", subtitle: "See how far you've come", delay: 1.4)
                            ReturningUserFeatureRow(icon: "target", title: "Continue your goals", subtitle: "Pick up where you left off", delay: 1.6)
                            ReturningUserFeatureRow(icon: "sparkles", title: "New AI features", subtitle: "Enhanced nutrition coaching", delay: 1.8)
                        }
                        .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                        .opacity(showSecondaryElements ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8).delay(1.4), value: showSecondaryElements)
                    }
                    
                    Spacer()
                    
                    // Continue button
                    Button(action: {
                        shouldShowReturningUserWelcome = false
                    }) {
                        HStack {
                            Text("Let's Continue!")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.blue)
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                    }
                    .scaleEffect(showSecondaryElements ? 1.0 : 0.9)
                    .opacity(showSecondaryElements ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(2.0), value: showSecondaryElements)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // Get days since last visit for display
            daysSinceLastVisit = UserActivityService.shared.daysSinceLastActivity() ?? 0
            
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
        // Fallback to auth manager data
        return authManager.userFirstName.isEmpty ? nil : authManager.userFirstName
    }
}

struct ReturningUserFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let delay: Double
    @State private var show = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.cyan)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.white.opacity(0.6))
            }
            
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
