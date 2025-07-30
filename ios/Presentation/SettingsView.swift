// If UniversalBackground is not found, ensure the file is included in the target membership in Xcode.
import SwiftUI
// UniversalBackground is a local SwiftUI View

struct SettingsView: View {
    @State private var calorieGoal = ""
    let profileRepo = UserProfileRepository()
    var profile: UserProfile? { profileRepo.loadProfile() }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Settings")
                .font(.title)
                .foregroundColor(.white)
            TextField("Calorie Goal", text: $calorieGoal)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Save Calorie Goal") {
                if var profile = profile {
                    profile = UserProfile(
                        firstName: profile.firstName,
                        lastName: profile.lastName,
                        age: profile.age,
                        dob: profile.dob,
                        height: profile.height,
                        weight: Float(calorieGoal) ?? profile.weight
                    )
                    profileRepo.saveProfile(profile)
                }
            }
            Divider()
            Text("Profile")
                .font(.headline)
                .foregroundColor(.white)
            Text("Notifications")
                .font(.headline)
                .foregroundColor(.white)
            Text("Privacy")
                .font(.headline)
                .foregroundColor(.white)
            Text("About")
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(UniversalBackground())
        .onAppear {
            if let profile = profile {
                calorieGoal = String(profile.weight)
            }
        }
    }
}
