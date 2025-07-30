import SwiftUI

struct BMICalculatorView: View {
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
        VStack(spacing: 24) {
            Text("BMI & Calorie Calculator")
                .font(.title)
                .foregroundColor(.white)
            TextField("Height (cm)", text: $height)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Weight (kg)", text: $weight)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Age", text: $age)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Picker("Gender", selection: $gender) {
                Text("Male").tag("Male")
                Text("Female").tag("Female")
            }
            .pickerStyle(SegmentedPickerStyle())
            Picker("Activity Level", selection: $activityLevel) {
                Text("Sedentary").tag("Sedentary")
                Text("Lightly Active").tag("Lightly Active")
                Text("Moderately Active").tag("Moderately Active")
                Text("Very Active").tag("Very Active")
            }
            Picker("Goal", selection: $goal) {
                Text("Lose Weight").tag("Lose Weight")
                Text("Gain Muscle").tag("Gain Muscle")
                Text("Maintain Weight").tag("Maintain Weight")
            }
            let profileRepo = UserProfileRepository()
            Button("Calculate & Save") {
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

                // Save calorie goal to user profile
                if var profile = profileRepo.loadProfile() {
                    profile = UserProfile(
                        firstName: profile.firstName,
                        lastName: profile.lastName,
                        age: profile.age,
                        dob: profile.dob,
                        height: Float(h),
                        weight: Float(w)
                    )
                    profileRepo.saveProfile(profile)
                }
            }
            Text("BMI: \(String(format: "%.2f", bmi))")
            Text("Recommended Calories: \(String(format: "%.0f", calorieGoal))")
        }
        .padding()
        .background(Color.black)
    }
}
