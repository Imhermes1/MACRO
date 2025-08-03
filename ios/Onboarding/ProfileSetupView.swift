import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isOnboardingComplete: Bool
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var dob = ""
    @State private var height = ""
    @State private var weight = ""
    @State private var gender = "Male"
    @State private var showDobIncentive = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var hasPrefilledData = false
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    private let profileRepo = UserProfileRepository()
    
    enum Field: Hashable {
        case firstName, lastName, age, dob, height, weight, gender
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                UniversalBackground()
                
                VStack(spacing: focusedField != nil ? 20 : 30) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Complete Profile")
                            .font(.system(size: 32, weight: .thin))
                            .foregroundColor(.white)
                            .tracking(4)
                            .opacity(0.95)
                        
                        if hasPrefilledData {
                            Text("We've pre-filled some information from your account")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, max(8, geometry.safeAreaInsets.top))
                    .onAppear {
                        // Pre-populate with data from authentication
                        if !hasPrefilledData {
                            firstName = authManager.userFirstName
                            lastName = authManager.userLastName
                            hasPrefilledData = true
                            print("Pre-populated profile with - First: '\(firstName)', Last: '\(lastName)'")
                        }
                    }
                    
                    // Form fields in a scrollable container
                    ScrollView {
                        VStack(spacing: 16) {
                            // First Name
                            CustomTextField(
                                text: $firstName,
                                placeholder: "First Name*",
                                focusedField: $focusedField,
                                currentField: .firstName,
                                nextField: .lastName
                            )
                            
                            // Last Name
                            CustomTextField(
                                text: $lastName,
                                placeholder: "Last Name (optional)",
                                focusedField: $focusedField,
                                currentField: .lastName,
                                nextField: .age
                            )
                            
                            // Age
                            CustomTextField(
                                text: $age,
                                placeholder: "Age*",
                                keyboardType: .numberPad,
                                focusedField: $focusedField,
                                currentField: .age,
                                nextField: .height
                            )
                            
                            // Date of Birth with incentive button
                            HStack(alignment: .center, spacing: 8) {
                                CustomTextField(
                                    text: $dob,
                                    placeholder: "Date of Birth (DD/MM/YYYY)",
                                    keyboardType: .numberPad,
                                    focusedField: $focusedField,
                                    currentField: .dob,
                                    nextField: .height
                                )
                                
                                Button(action: {
                                    showDobIncentive.toggle()
                                }) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                                .alert("Birthday Surprise! 🎉", isPresented: $showDobIncentive) {
                                    Button("OK") { }
                                } message: {
                                    Text("If you provide your Date of Birth, we might surprise you on your birthday!")
                                }
                            }
                            
                            // Height
                            CustomTextField(
                                text: $height,
                                placeholder: "Height (cm)*",
                                keyboardType: .decimalPad,
                                focusedField: $focusedField,
                                currentField: .height,
                                nextField: .weight
                            )
                            
                            // Weight
                            CustomTextField(
                                text: $weight,
                                placeholder: "Weight (kg)*",
                                keyboardType: .decimalPad,
                                focusedField: $focusedField,
                                currentField: .weight,
                                nextField: nil
                            )
                            
                            // Gender
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Gender*")
                                        .foregroundColor(.white.opacity(0.6))
                                        .font(.system(size: 16))
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                
                                HStack(spacing: 12) {
                                    Button(action: { gender = "Male" }) {
                                        HStack {
                                            Image(systemName: gender == "Male" ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(gender == "Male" ? .blue : .white.opacity(0.6))
                                            Text("Male")
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.black.opacity(0.2))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(gender == "Male" ? Color.blue : Color.black, lineWidth: 1)
                                        )
                                    }
                                    
                                    Button(action: { gender = "Female" }) {
                                        HStack {
                                            Image(systemName: gender == "Female" ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(gender == "Female" ? .blue : .white.opacity(0.6))
                                            Text("Female")
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.black.opacity(0.2))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(gender == "Female" ? Color.blue : Color.black, lineWidth: 1)
                                        )
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            // Save button
                            NavigationLink(destination: GoalsSetupView(isOnboardingComplete: $isOnboardingComplete)) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text(isLoading ? "Saving..." : "Continue to Goals Setup")
                                        .fontWeight(.semibold)
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.blue)
                                )
                                .scaleEffect(isLoading ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isLoading)
                            }
                            .disabled(isLoading || !isFormValid)
                            .simultaneousGesture(TapGesture().onEnded {
                                saveProfile()
                            })
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 20)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Small logout button in bottom right corner
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            Task {
                                await authManager.signOut()
                            }
                        }) {
                            Image(systemName: "power")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .overlay(
                                            Circle()
                                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, max(16, geometry.safeAreaInsets.bottom + 8))
                    }
                }
                .allowsHitTesting(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onTapGesture {
            focusedField = nil
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            loadUserData()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Profile"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !age.isEmpty &&
        !height.isEmpty &&
        !weight.isEmpty
    }
    
    private func saveProfile() {
        // Dismiss keyboard first
        focusedField = nil
        
        // Validate required fields
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAge = age.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHeight = height.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWeight = weight.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFirstName.isEmpty, !trimmedAge.isEmpty, !trimmedHeight.isEmpty, !trimmedWeight.isEmpty else {
            alertMessage = "Please fill in all required fields (marked with *)."
            showAlert = true
            return
        }
        
        // Validate numeric inputs with better error handling
        guard let ageInt = Int(trimmedAge), ageInt > 0 && ageInt < 150 else {
            alertMessage = "Please enter a valid age between 1 and 149."
            showAlert = true
            return
        }
        
        guard let heightFloat = Float(trimmedHeight.replacingOccurrences(of: ",", with: ".")),
              heightFloat > 0 && heightFloat < 300 else {
            alertMessage = "Please enter a valid height in centimeters (1-299)."
            showAlert = true
            return
        }
        
        guard let weightFloat = Float(trimmedWeight.replacingOccurrences(of: ",", with: ".")),
              weightFloat > 0 && weightFloat < 1000 else {
            alertMessage = "Please enter a valid weight in kilograms (1-999)."
            showAlert = true
            return
        }
        
        // Validate DOB format if provided
        let trimmedDob = dob.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedDob.isEmpty && !isValidDateFormat(trimmedDob) {
            alertMessage = "Please enter date of birth in DD/MM/YYYY format (e.g., 15/03/1990)."
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Create and save profile
        let profile = UserProfile(
            firstName: trimmedFirstName,
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            age: ageInt,
            dob: trimmedDob.isEmpty ? nil : trimmedDob,
            height: heightFloat,
            weight: weightFloat
        )
        
        // Save profile - this is synchronous so we handle it properly
        profileRepo.saveProfile(profile)
        
        // Success feedback
        isLoading = false
        // Remove the alert since we're navigating away
    }
    
    private func isValidDateFormat(_ dateString: String) -> Bool {
        let dateRegex = #"^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$"#
        return NSPredicate(format: "SELF MATCHES %@", dateRegex).evaluate(with: dateString)
    }
    
    private func loadUserData() {
        // You might want to get user details from your AuthManager's session
        // For now, this is left as is, but you should adapt it to your new auth flow
    }
}

// Custom TextField component with better keyboard handling
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var focusedField: FocusState<ProfileSetupView.Field?>.Binding
    let currentField: ProfileSetupView.Field
    let nextField: ProfileSetupView.Field?
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.2))
            )
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 1)
            )
            .overlay(
                // Custom placeholder
                HStack {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.leading, 16)
                    }
                    Spacer()
                }
                .allowsHitTesting(false)
            )
            .focused(focusedField, equals: currentField)
            .onSubmit {
                if let nextField = nextField {
                    focusedField.wrappedValue = nextField
                } else {
                    focusedField.wrappedValue = nil
                }
            }
            .submitLabel(nextField != nil ? .next : .done)
    }
}
