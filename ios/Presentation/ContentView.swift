import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var userProfileRepository = UserProfileRepository()
    @State private var isOnboardingComplete = false

    var body: some View {
        if authManager.session != nil {
            if userProfileRepository.hasProfile || isOnboardingComplete {
                // User has completed onboarding - show main app
                NavigationStack {
                    MainAppView()
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
                }
        }
    }
}
