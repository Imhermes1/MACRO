import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @StateObject private var userProfileRepository = UserProfileRepository()
    
    var body: some View {
        NavigationStack {
            ProfileSetupView(isOnboardingComplete: $isOnboardingComplete)
        }
        .environmentObject(userProfileRepository)
    }
}
