import SwiftUI

struct ProfileSetupView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var dob = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var showDobIncentive = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    let profileRepo = UserProfileRepository()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Set up your profile")
                .font(.title)
                .foregroundColor(.white)
            TextField("First Name*", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Last Name (optional)", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Age*", text: $age)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Date of Birth (optional)", text: $dob, onEditingChanged: { editing in showDobIncentive = editing })
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if showDobIncentive {
                Text("Provide your DOB for personalized insights and rewards!")
                    .foregroundColor(.blue)
            }
            TextField("Height*", text: $height)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Weight*", text: $weight)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Save Profile") {
                guard !firstName.isEmpty, !age.isEmpty, !height.isEmpty, !weight.isEmpty else {
                    alertMessage = "Please fill in all required fields."
                    showAlert = true
                    return
                }
                guard let ageInt = Int(age), let heightFloat = Float(height), let weightFloat = Float(weight) else {
                    alertMessage = "Please enter valid numbers for age, height, and weight."
                    showAlert = true
                    return
                }
                let profile = UserProfile(
                    firstName: firstName,
                    lastName: lastName.isEmpty ? nil : lastName,
                    age: ageInt,
                    dob: dob.isEmpty ? nil : dob,
                    height: heightFloat,
                    weight: weightFloat
                )
                profileRepo.saveProfile(profile)
                FirebaseService().saveGroup(Group(id: "profile_\(firstName)", name: firstName, members: [firstName]))
                alertMessage = "Profile saved and synced!"
                showAlert = true
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .background(Color.black)
    }
}
