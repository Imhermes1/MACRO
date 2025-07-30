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
                VStack {
                    // Add a logout button at the top for testing
                    HStack {
                        Spacer()
                        Button("Logout") {
                            session.signOut()
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                    }
                    
                    VStack(spacing: 20) {
                        Text("Complete your profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if hasPrefilledData {
                            Text("We've pre-filled some information from your account")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer().frame(height: 10)
                        
                        VStack(spacing: 15) {
                            StyledTextField(text: $firstName, placeholder: "First Name*")
                            StyledTextField(text: $lastName, placeholder: "Last Name (optional)")
                            StyledTextField(text: $age, placeholder: "Age*", keyboardType: .numberPad)
                            StyledTextField(text: $dob, placeholder: "Date of Birth (optional)", keyboardType: .numberPad, onEditingChanged: { editing in 
                                showDobIncentive = editing && !dob.isEmpty
                            })
                            
                            if showDobIncentive {
                                Text("Provide your DOB for personalized insights and rewards!")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.footnote)
                            }
                            
                            StyledTextField(text: $height, placeholder: "Height (cm)*", keyboardType: .decimalPad)
                            StyledTextField(text: $weight, placeholder: "Weight (kg)*", keyboardType: .decimalPad)
                        }
                        
                        Spacer().frame(height: 30)
                        
                        Button(action: {
                            // Hide keyboard when button is pressed
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
                            
                            do {
                                let profile = UserProfile(
                                    firstName: firstName,
                                    lastName: lastName.isEmpty ? nil : lastName,
                                    age: ageInt,
                                    dob: dob.isEmpty ? nil : dob,
                                    height: heightFloat,
                                    weight: weightFloat
                                )
                                profileRepo.saveProfile(profile)
                                
                                // Create and save group
                                let group = Group(id: "profile_\(firstName)", name: firstName, members: [firstName])
                                FirebaseService().saveGroup(group)
                                
                                // Update session state
                                DispatchQueue.main.async {
                                    self.session.checkUserProfile()
                                    self.isLoading = false
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    self.alertMessage = "Error saving profile: \(error.localizedDescription)"
                                    self.showAlert = true
                                    self.isLoading = false
                                }
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "Saving..." : "Save Profile")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(isLoading ? 0.1 : 0.2))
                            .clipShape(Capsule())
                        }
                        .disabled(isLoading)
                    }
                    .padding(32)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            hideKeyboard()
        } // Move this to the ZStack level
        .onAppear {
                // Auto-populate fields from Firebase Auth user data
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}