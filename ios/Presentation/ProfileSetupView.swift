// If UniversalBackground is not found, ensure the file is included in the target membership in Xcode.
import SwiftUI
// UniversalBackground is a local SwiftUI View

// If UniversalBackground is not found, ensure the file is included in the target membership in Xcode.
import SwiftUI
// UniversalBackground is a local SwiftUI View

struct ProfileSetupView: View {
    @ObservedObject var session: SessionStore
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var dob = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var showDobIncentive = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var hasPrefilledData = false
    @State private var isLoading = false
    let profileRepo = UserProfileRepository()
    
    var body: some View {
        ZStack {
            UniversalBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Centered header at top
                    VStack(spacing: 10) {
                        Text("Complete your profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        if hasPrefilledData {
                            Text("We've pre-filled some information from your account")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Logout button positioned separately
                    HStack {
                        Spacer()
                        Button("Logout") {
                            session.signOut()
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                    }
                    
                    // Form fields with improved spacing
                    VStack(spacing: 15) {
                        StyledTextField(text: $firstName, placeholder: "First Name*")
                        StyledTextField(text: $lastName, placeholder: "Last Name (optional)")
                        StyledTextField(text: $age, placeholder: "Age*", keyboardType: .numberPad)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                StyledTextField(text: $dob, placeholder: "Date of Birth (optional)", keyboardType: .numberPad)
                                
                                Button(action: {
                                    showDobIncentive.toggle()
                                }) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                                .popover(isPresented: $showDobIncentive) {
                                    VStack(spacing: 12) {
                                        Text("Birthday Surprise! 🎉")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Text("If you provide your Date of Birth, we'll do something special for you on your birthday!")
                                            .font(.body)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding()
                                    .frame(maxWidth: 280)
                                }
                            }
                        }
                        
                        StyledTextField(text: $height, placeholder: "Height (cm)*", keyboardType: .decimalPad)
                        StyledTextField(text: $weight, placeholder: "Weight (kg)*", keyboardType: .decimalPad)
                    }
                    .padding(.horizontal, 32)
                    
                    // Save button with better feedback
                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Saving..." : "Save Profile")
                                .fontWeight(.semibold)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(isLoading ? 0.1 : 0.2))
                        .clipShape(Capsule())
                        .scaleEffect(isLoading ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLoading)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 32)
                    .padding(.top, 20)
                }
                .padding(.vertical, 32)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            loadUserData()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func saveProfile() {
        hideKeyboard()
        
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
        
        isLoading = true
        
        let profile = UserProfile(
            firstName: firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            age: ageInt,
            dob: dob.isEmpty ? nil : dob,
            height: heightFloat,
            weight: weightFloat
        )
        
        // Save profile and handle potential errors
        profileRepo.saveProfile(profile)
        
        // Show success message and update session
        alertMessage = "Profile saved successfully!"
        showAlert = true
        
        // Update session state after delay to ensure save completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.session.checkUserProfile()
            self.isLoading = false
        }
    }
    
    private func loadUserData() {
        let userDetails = session.extractUserDetails()
        var dataWasPreFilled = false
        
        if let first = userDetails.firstName, firstName.isEmpty {
            firstName = first
            dataWasPreFilled = true
        }
        if let last = userDetails.lastName, lastName.isEmpty {
            lastName = last
            dataWasPreFilled = true
        }
        
        hasPrefilledData = dataWasPreFilled
    }
    
    private func hideKeyboard() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        windowScene?.windows.first?.endEditing(true)
    }
}

