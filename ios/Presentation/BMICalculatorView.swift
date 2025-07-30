import SwiftUI
// UniversalBackground is a local SwiftUI View

struct BMICalculatorView: View {
    @ObservedObject var session: SessionStore
    @State private var height = ""
    @State private var weight = ""
    @State private var age = ""
    @State private var gender = "Male"
    @State private var activityLevel = "Sedentary"
    @State private var goal = "Maintain Weight"
    @State private var bmi: Double = 0.0
    @State private var bmr: Double = 0.0
    @State private var calorieGoal: Double = 0.0
    
    var body: some View {
        ZStack {
            UniversalBackground()
            ScrollView {
                VStack(spacing: 20) {
                    Text("BMI & Calorie Calculator")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer().frame(height: 10)
                    
                    VStack(spacing: 15) {
                        StyledTextField(text: $height, placeholder: "Height (cm)", keyboardType: .decimalPad)
                        StyledTextField(text: $weight, placeholder: "Weight (kg)", keyboardType: .decimalPad)
                        StyledTextField(text: $age, placeholder: "Age", keyboardType: .numberPad)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    Button(action: {
                        // Hide keyboard when button is pressed
                        hideKeyboard()
                        
                        let h = Double(height) ?? 0.0
                        let w = Double(weight) ?? 0.0
                        let a = Int(age) ?? 0
                        let meters = h / 100.0
                        bmi = meters > 0 ? w / (meters * meters) : 0.0
                        if gender == "Male" {
                            bmr = 10 * w + 6.25 * h - 5 * Double(a) + 5
                        } else {
                            bmr = 10 * w + 6.25 * h - 5 * Double(a) - 161
                        }
                        let activityMultiplier: Double
                        switch activityLevel {
                        case "Sedentary": activityMultiplier = 1.2
                        case "Lightly Active": activityMultiplier = 1.375
                        case "Moderately Active": activityMultiplier = 1.55
                        case "Very Active": activityMultiplier = 1.725
                        default: activityMultiplier = 1.2
                        }
                        var goalAdjustment = 0.0
                        switch goal {
                        case "Lose Weight": goalAdjustment = -500.0
                        case "Gain Muscle": goalAdjustment = 300.0
                        case "Maintain Weight": goalAdjustment = 0.0
                        default: goalAdjustment = 0.0
                        }
                        calorieGoal = bmr * activityMultiplier + goalAdjustment

                        let profileRepo = UserProfileRepository()
                        if var profile = profileRepo.loadProfile() {
                            profile = UserProfile(
                                firstName: profile.firstName,
                                lastName: profile.lastName,
                                age: Int(age) ?? profile.age,
                                dob: profile.dob,
                                height: Float(h),
                                weight: Float(w)
                            )
                            profileRepo.saveProfile(profile)
                            
                            // Update session to reflect BMI completion
                            session.checkUserProfile()
                        }
                    }) {
                        Text("Calculate & Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    Spacer().frame(height: 20)
                    
                    VStack(spacing: 10) {
                        Text("BMI: \(String(format: "%.2f", bmi))")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text("Recommended Calories: \(String(format: "%.0f", calorieGoal))")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .padding(32)
                .frame(minHeight: UIScreen.main.bounds.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.all) // Ensure full screen coverage
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            // Auto-populate fields from saved profile data
            let profileRepo = UserProfileRepository()
            if let profile = profileRepo.loadProfile() {
                if height.isEmpty && profile.height > 0 {
                    height = String(profile.height)
                }
                if weight.isEmpty && profile.weight > 0 {
                    weight = String(profile.weight)
                }
                if age.isEmpty && profile.age > 0 {
                    age = String(profile.age)
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
