import SwiftUI

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
    @FocusState private var focusedField: Field?
    
    private let profileRepo = UserProfileRepository()
    
    enum Field: Hashable {
        case firstName, lastName, age, dob, height, weight
    }
    
    var body: some View {
        ZStack {
            UniversalBackground()
            
            VStack(spacing: 0) {
                // Header with logout button
                HStack {
                    Text("Complete Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Logout") {
                        session.signOut()
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .font(.body)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                if hasPrefilledData {
                    Text("We've pre-filled some information from your account")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 5)
                }
                
                // Scrollable form
                ScrollView {
                    VStack(spacing: 20) {
                        // Form fields
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
                        }
                        .padding(.horizontal, 20)
                        
                        // Save button
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
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(isLoading ? 0.1 : 0.2))
                            )
                            .scaleEffect(isLoading ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isLoading)
                        }
                        .disabled(isLoading || !isFormValid)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Extra padding for keyboard
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.top, 20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
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
                dismissButton: .default(Text("OK")) {
                    if alertMessage.contains("successfully") {
                        // Navigate to next screen after successful save
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                session.checkUserProfile()
                            }
                        }
                    }
                }
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
        
        // Create profile with error handling
        do {
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
            alertMessage = "Profile saved successfully! 🎉"
            showAlert = true
            
        } catch {
            // Handle any potential errors
            isLoading = false
            alertMessage = "Failed to save profile. Please try again."
            showAlert = true
            print("Profile save error: \(error)")
        }
    }
    
    private func isValidDateFormat(_ dateString: String) -> Bool {
        let dateRegex = #"^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$"#
        return NSPredicate(format: "SELF MATCHES %@", dateRegex).evaluate(with: dateString)
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
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            .foregroundColor(Color.white)
            .accentColor(Color.white)
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
