import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var userProfileRepository = UserProfileRepository()
    @State private var isOnboardingComplete = false
    @State private var shouldShowReturningUserWelcome = false

    var body: some View {
        SwiftUI.Group {
            if authManager.session != nil {
                if shouldShowReturningUserWelcome {
                    // Show welcome screen for returning users after 3+ days
                    ReturningUserWelcomeView(shouldShowReturningUserWelcome: $shouldShowReturningUserWelcome)
                        .environmentObject(userProfileRepository)
                } else if userProfileRepository.hasProfile || isOnboardingComplete {
                    // User has completed onboarding - show main app
                    NavigationStack {
                        MainAppView()
                            .onAppear {
                                // Record activity when user enters main app
                                UserActivityService.shared.recordActivity()
                            }
                    }
                } else {
                    // User needs to complete onboarding
                    OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                        .environmentObject(userProfileRepository)
                }
            } else {
                LoginView()
                    .onAppear {
                        // Reset onboarding state when returning to login
                        isOnboardingComplete = false
                        shouldShowReturningUserWelcome = false
                    }
            }
        }
        .onChange(of: authManager.session) { _, newSession in
            // When session changes, handle state properly
            if newSession != nil {
                // User signed in - check for returning user welcome
                checkForReturningUserWelcome()
            } else {
                // User signed out - reset all onboarding state immediately
                isOnboardingComplete = false
                shouldShowReturningUserWelcome = false
                
                // Force profile repository refresh
                if userProfileRepository.hasProfile {
                    userProfileRepository.clearProfile()
                }
                
                print("📱 ContentView: Reset to login state")
            }
        }
        .onChange(of: userProfileRepository.hasProfile) { _, hasProfile in
            // Check for returning user welcome when profile status changes
            if hasProfile && authManager.session != nil {
                checkForReturningUserWelcome()
            }
        }
    }
    
    // Check for returning user welcome when session changes
    private func checkForReturningUserWelcome() {
        // Only check if user has a profile (completed onboarding before)
        if authManager.session != nil && userProfileRepository.hasProfile {
            shouldShowReturningUserWelcome = UserActivityService.shared.shouldShowWelcomeForReturningUser()
        }
    }
    
    // Monitor auth session and profile changes
    private var shouldCheckReturningUser: Bool {
        authManager.session != nil && userProfileRepository.hasProfile
    }
}
