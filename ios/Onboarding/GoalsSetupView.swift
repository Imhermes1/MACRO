import SwiftUI

struct GoalsSetupView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isOnboardingComplete: Bool
    @State private var goal = "Maintain Weight"
    @State private var activityLevel = "Sedentary"
    @State private var macroPreference = "Balanced"
    @State private var customDietText = ""
    @State private var bmi: Double = 0.0
    @State private var calorieGoal: Double = 0.0
    @State private var isLoading = false
    
    private let profileRepo = UserProfileRepository()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                UniversalBackground()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Goals & Health")
                            .font(.system(size: 32, weight: .thin))
                            .foregroundColor(.white)
                            .tracking(4)
                            .opacity(0.95)
                        
                        Text("Set your fitness goals and preferences")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, max(8, geometry.safeAreaInsets.top))
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // BMI Display Section
                            VStack(spacing: 12) {
                                Text("Your BMI")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Text("\(String(format: "%.1f", bmi))")
                                        .font(.system(size: 36, weight: .thin))
                                        .foregroundColor(bmiColor)
                                    
                                    Circle()
                                        .fill(bmiColor)
                                        .frame(width: 12, height: 12)
                                }
                                
                                Text(bmiCategory)
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            
                            // Primary Goal Section
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Primary Goal*")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(["Lose Weight", "Gain Weight", "Maintain Weight", "Build Muscle", "Improve Fitness", "General Health"], id: \.self) { goalOption in
                                        Button(action: { goal = goalOption }) {
                                            Text(goalOption)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(Color.black.opacity(0.2))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(goal == goalOption ? Color.blue : Color.black, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                            
                            // Activity Level Section
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Activity Level*")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(["Sedentary", "Lightly Active", "Moderately Active", "Very Active"], id: \.self) { activity in
                                        Button(action: { activityLevel = activity }) {
                                            HStack {
                                                Image(systemName: activityLevel == activity ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(activityLevel == activity ? .blue : .white.opacity(0.6))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(activity)
                                                        .font(.system(size: 16, weight: .medium))
                                                        .foregroundColor(.white)
                                                    Text(activityDescription(activity))
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white.opacity(0.6))
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.black.opacity(0.2))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(activityLevel == activity ? Color.blue : Color.black, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Diet Style Section
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Diet Style*")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(["Balanced", "High Protein", "Low Carb", "Custom"], id: \.self) { macro in
                                        Button(action: { 
                                            macroPreference = macro
                                            // Clear custom text if switching away from Custom
                                            if macro != "Custom" {
                                                customDietText = ""
                                            }
                                        }) {
                                            Text(macro)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 12)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(Color.black.opacity(0.2))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(macroPreference == macro ? Color.blue : Color.black, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                
                                // Custom diet text field - appears when Custom is selected
                                if macroPreference == "Custom" {
                                    VStack(spacing: 8) {
                                        HStack {
                                            Text("Describe your custom diet preference:")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white.opacity(0.8))
                                            Spacer()
                                        }
                                        
                                        TextField("e.g., Keto, Paleo, Mediterranean, etc.", text: $customDietText)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.black.opacity(0.2))
                                            )
                                            .foregroundColor(.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                            )
                                            .overlay(
                                                // Custom placeholder
                                                HStack {
                                                    if customDietText.isEmpty {
                                                        Text("e.g., Keto, Paleo, Mediterranean, etc.")
                                                            .foregroundColor(.white.opacity(0.5))
                                                            .padding(.leading, 16)
                                                    }
                                                    Spacer()
                                                }
                                                .allowsHitTesting(false)
                                            )
                                    }
                                    .padding(.top, 8)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    .animation(.easeInOut(duration: 0.3), value: macroPreference)
                                }
                            }
                            
                            // Complete Setup Button
                            Button(action: {
                                completeSetup()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    Text(isLoading ? "Setting up..." : "Complete Setup")
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
                            .disabled(isLoading)
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
        .onAppear {
            calculateBMI()
        }
    }
    
    private var bmiColor: Color {
        switch bmi {
        case ..<18.5: return .blue      // Underweight
        case 18.5..<25: return .green   // Normal
        case 25..<30: return .orange    // Overweight
        default: return .red            // Obese
        }
    }
    
    private var bmiCategory: String {
        switch bmi {
        case ..<18.5: return "Underweight - You may benefit from gaining weight"
        case 18.5..<25: return "Normal weight - You're in a healthy range"
        case 25..<30: return "Overweight - Consider a healthy weight loss plan"
        default: return "Obese - Consult with a healthcare professional"
        }
    }
    
    private func activityDescription(_ activity: String) -> String {
        switch activity {
        case "Sedentary": return "Little to no exercise"
        case "Lightly Active": return "Light exercise 1-3 days/week"
        case "Moderately Active": return "Moderate exercise 3-5 days/week"
        case "Very Active": return "Heavy exercise 6-7 days/week"
        default: return ""
        }
    }
    
    private func calculateBMI() {
        if let profile = profileRepo.loadProfile() {
            let heightInMeters = profile.height / 100.0
            if heightInMeters > 0 {
                bmi = Double(profile.weight) / (Double(heightInMeters) * Double(heightInMeters))
            }
        }
    }
    
    private func completeSetup() {
        isLoading = true
        
        // Calculate calorie goal
        calculateCalorieGoal()
        
        // Save goals and preferences
        saveGoalsAndPreferences()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            isOnboardingComplete = true
        }
    }
    
    private func saveGoalsAndPreferences() {
        // Save all goals and preferences to UserDefaults
        UserDefaults.standard.set(goal, forKey: "user_goal")
        UserDefaults.standard.set(activityLevel, forKey: "user_activity_level")
        UserDefaults.standard.set(macroPreference, forKey: "user_macro_preference")
        
        // Save custom diet text if "Custom" is selected
        if macroPreference == "Custom" {
            UserDefaults.standard.set(customDietText, forKey: "user_custom_diet")
        } else {
            UserDefaults.standard.removeObject(forKey: "user_custom_diet")
        }
        
        UserDefaults.standard.set(calorieGoal, forKey: "user_calorie_goal")
        print("Saved goals: Goal=\(goal), Activity=\(activityLevel), Diet=\(macroPreference), Custom=\(customDietText), Calories=\(calorieGoal)")
    }
    
    private func calculateCalorieGoal() {
        guard let profile = profileRepo.loadProfile() else { return }
        
        let weight = Double(profile.weight)
        let height = Double(profile.height)
        let age = Double(profile.age)
        
        // Calculate BMR using Mifflin-St Jeor Equation
        let bmr: Double
        // Note: We'll need to get gender from profile - for now using a default
        // This should be updated once gender is added to UserProfile
        bmr = 10 * weight + 6.25 * height - 5 * age + 5 // Male formula as default
        
        // Activity multiplier
        let activityMultiplier: Double
        switch activityLevel {
        case "Sedentary": activityMultiplier = 1.2
        case "Lightly Active": activityMultiplier = 1.375
        case "Moderately Active": activityMultiplier = 1.55
        case "Very Active": activityMultiplier = 1.725
        default: activityMultiplier = 1.2
        }
        
        // Goal adjustment
        let goalAdjustment: Double
        switch goal {
        case "Lose Weight": goalAdjustment = -500
        case "Gain Weight": goalAdjustment = 300
        case "Build Muscle": goalAdjustment = 300
        default: goalAdjustment = 0
        }
        
        calorieGoal = bmr * activityMultiplier + goalAdjustment
    }
}
