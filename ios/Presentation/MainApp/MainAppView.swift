import SwiftUI

struct MainAppView: View {
    @State private var showOnboardingDemo = false
    @State private var currentInput = ""
    @State private var todaysCalories = 0
    @State private var calorieGoal = 2000
    
    var body: some View {
        ZStack {
            UniversalBackground()
            
            VStack(spacing: 0) {
                // Top navigation bar
                TopNavigationBar()
                
                // Main content area
                ScrollView {
                    VStack(spacing: 20) {
                        // Daily progress card
                        DailyProgressCard(
                            currentCalories: todaysCalories,
                            goalCalories: calorieGoal
                        )
                        
                        // Recent entries or placeholder
                        RecentEntriesSection()
                        
                        // Quick tips or motivational content
                        QuickTipsCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for floating input bar
                }
                
                Spacer()
            }
            
            // Floating input bar at bottom
            VStack {
                Spacer()
                FloatingCalorieInputBar(currentInput: $currentInput) { calories in
                    // Handle calorie input
                    todaysCalories += calories
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 34) // Safe area bottom
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            // Show demo on first launch
            if !UserDefaults.standard.bool(forKey: "has_seen_app_demo") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showOnboardingDemo = true
                }
            }
        }
        .sheet(isPresented: $showOnboardingDemo) {
            OnboardingDemoView {
                UserDefaults.standard.set(true, forKey: "has_seen_app_demo")
                showOnboardingDemo = false
            }
        }
    }
}

// MARK: - Top Navigation Bar
struct TopNavigationBar: View {
    var body: some View {
        HStack {
            // App title/logo
            HStack(spacing: 8) {
                Image("LumoraLabsLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                Text("MACRO")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Settings/profile button
            Button(action: {
                // Navigate to settings
            }) {
                Image(systemName: "person.circle")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .blur(radius: 10)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Daily Progress Card
struct DailyProgressCard: View {
    let currentCalories: Int
    let goalCalories: Int
    
    private var progress: Double {
        guard goalCalories > 0 else { return 0 }
        return min(Double(currentCalories) / Double(goalCalories), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(currentCalories) / \(goalCalories) cal")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                VStack(spacing: 4) {
                    Text("\(Int(progress * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(goalCalories - currentCalories) left")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Recent Entries Section
struct RecentEntriesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Entries")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("View All") {
                    // Navigate to full history
                }
                .font(.subheadline)
                .foregroundColor(.yellow)
            }
            
            // Placeholder for when there are no entries yet
            VStack(spacing: 16) {
                Image(systemName: "plus.circle.dashed")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
                
                Text("Start tracking your nutrition!")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Use the input bar below to add your first meal or snack")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Quick Tips Card
struct QuickTipsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Quick Tip")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            Text("💡 Try saying: \"I had a banana and coffee for breakfast\" or \"Large pizza slice, 350 calories\"")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.1))
                .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Floating Input Bar
struct FloatingCalorieInputBar: View {
    @Binding var currentInput: String
    let onCaloriesAdded: (Int) -> Void
    
    @State private var isRecording = false
    @State private var showVoiceAnimation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Voice input button
            Button(action: {
                isRecording.toggle()
                if isRecording {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        showVoiceAnimation = true
                    }
                } else {
                    showVoiceAnimation = false
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isRecording ? Color.red.opacity(0.2) : Color.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .scaleEffect(showVoiceAnimation ? 1.2 : 1.0)
                    
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.title3)
                        .foregroundColor(isRecording ? .red : .white)
                }
            }
            
            // Text input field
            TextField("What did you eat?", text: $currentInput)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.1))
                )
            
            // Send button
            Button(action: {
                // Process input and extract calories
                // For now, just add a placeholder amount
                onCaloriesAdded(250)
                currentInput = ""
            }) {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "arrow.up")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    )
            }
            .disabled(currentInput.isEmpty)
            .opacity(currentInput.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    MainAppView()
}
