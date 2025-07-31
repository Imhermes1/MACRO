import SwiftUI

struct MainAppView: View {
    @State private var showOnboardingDemo = false
    @State private var currentInput = ""
    @State private var todaysCalories = 0
    @State private var calorieGoal = 2000
    @State private var isProgressExpanded = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Add safe area padding for the NavigationBar
                Spacer()
                    .frame(height: 100) // Account for status bar + NavigationBar height
                
                // Spacer where dropdown used to be
                Spacer()
                    .frame(height: 80) // Space for the dropdown
                
                // Main content area
                ScrollView {
                    VStack(spacing: 20) {
                        // Add minimal top padding since progress bar now handles spacing
                        Spacer()
                            .frame(height: 20) // Reduced padding since progress bar is properly positioned
                        
                        // Recent entries or placeholder
                        RecentEntriesSection()
                        
                        // Quick tips or motivational content
                        QuickTipsCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100) // Space for floating input bar
                }
                .background(Color.clear)
                
                Spacer()
            }
            
            // NavigationBar sits on top of all content (from Components/NavigationBar.swift)
            VStack {
                NavigationBar(
                    showTabDropdown: true,
                    showProfileButton: true,
                    profileAction: {
                        // Navigate to settings/profile
                    }
                )
                .padding(EdgeInsets(top: 44, leading: 16, bottom: 0, trailing: 16))
                Spacer()
            }
            .zIndex(10) // Highest z-index to ensure it's always on top
            
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
            
            // MOVED TO END: Dropdown Progress Bar - LAST in ZStack = on top of everything
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isProgressExpanded.toggle()
                }
            }) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 100) // Position below navigation
                    
                    DropdownProgressBar(
                        currentCalories: todaysCalories,
                        goalCalories: calorieGoal,
                        isExpanded: $isProgressExpanded
                    )
                    .padding(.horizontal, 12)
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .zIndex(5) // Lower z-index so navigation dropdown appears above it
            
            // MOVED TO END: Expanded dropdown content - separate layer on top
            if isProgressExpanded {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 160) // Position below the progress bar
                        .allowsHitTesting(false)
                    
                    ExpandedProgressContent(
                        currentCalories: todaysCalories,
                        goalCalories: calorieGoal,
                        currentProtein: 45,
                        goalProtein: 120,
                        currentCarbs: 85,
                        goalCarbs: 200,
                        currentFat: 25,
                        goalFat: 60
                    )
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 12)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)).combined(with: .offset(y: -10)),
                        removal: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)).combined(with: .offset(y: -10))
                    ))
                    
                    Spacer()
                        .allowsHitTesting(false)
                }
                .zIndex(16) // Higher than progress bar
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            // (Add onboarding logic here if needed)
        }
        .sheet(isPresented: $showOnboardingDemo) {
            // OnboardingDemoView - temporarily commented out
            Text("Demo View Placeholder")
                .onTapGesture {
                    UserDefaults.standard.set(true, forKey: "has_seen_app_demo")
                    showOnboardingDemo = false
                }
        }
    }
}

// MARK: - Dropdown Progress Bar
struct DropdownProgressBar: View {
    let currentCalories: Int
    let goalCalories: Int
    @Binding var isExpanded: Bool
    
    // Mock macronutrient data - in real app this would come from data layer
    private let currentProtein: Int = 45  // grams
    private let goalProtein: Int = 120
    private let currentCarbs: Int = 85    // grams
    private let goalCarbs: Int = 200
    private let currentFat: Int = 25      // grams
    private let goalFat: Int = 60
    
    private var progress: Double {
        guard goalCalories > 0 else { return 0 }
        return min(Double(currentCalories) / Double(goalCalories), 1.0)
    }
    
    // Calculate actual macro breakdown from consumed calories
    private var proteinCalories: Int { currentProtein * 4 }  // 4 cal per gram
    private var carbsCalories: Int { currentCarbs * 4 }      // 4 cal per gram  
    private var fatCalories: Int { currentFat * 9 }          // 9 cal per gram
    
    private var totalMacroCalories: Int {
        proteinCalories + carbsCalories + fatCalories
    }
    
    // Percentages of actual consumption (what portion of today's intake is each macro)
    private var proteinPercentage: Double {
        guard totalMacroCalories > 0 else { return 0 }
        return Double(proteinCalories) / Double(totalMacroCalories)
    }
    
    private var carbsPercentage: Double {
        guard totalMacroCalories > 0 else { return 0 }
        return Double(carbsCalories) / Double(totalMacroCalories)
    }
    
    private var fatPercentage: Double {
        guard totalMacroCalories > 0 else { return 0 }
        return Double(fatCalories) / Double(totalMacroCalories)
    }
    
    // Progress toward individual macro goals (for the detail rows)
    private var proteinProgress: Double {
        guard goalProtein > 0 else { return 0 }
        return min(Double(currentProtein) / Double(goalProtein), 1.0)
    }
    
    private var carbsProgress: Double {
        guard goalCarbs > 0 else { return 0 }
        return min(Double(currentCarbs) / Double(goalCarbs), 1.0)
    }
    
    private var fatProgress: Double {
        guard goalFat > 0 else { return 0 }
        return min(Double(currentFat) / Double(goalFat), 1.0)
    }
    
    private var remainingCalories: Int {
        max(goalCalories - currentCalories, 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Collapsed header bar - using Button wrapper for better touch handling
            VStack(spacing: 8) {
                // Top row with title and calories
                HStack(spacing: 12) {
                    Text("Today's Progress")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Text("\(currentCalories) / \(goalCalories) cal")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("(\(Int(progress * 100))%)")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.yellow)
                        
                        // Chevron indicator
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    }
                }
                
                // Progress bar with smooth animation
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 6)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(.spring(response: 1.0, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle()) // Make entire area tappable
            .background(.ultraThinMaterial)
            .overlay(
                // Subtle shadow overlay for depth
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.05),
                        Color.clear,
                        Color.black.opacity(0.02)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: .black.opacity(0.08),
                radius: 6,
                x: 0,
                y: 3
            )
        }
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
                    .fill(Color.cyan.opacity(0.08))
                    .strokeBorder(Color.cyan.opacity(0.2), lineWidth: 1)
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

// MARK: - Expanded Progress Content (Separate overlay component)
struct ExpandedProgressContent: View {
    let currentCalories: Int
    let goalCalories: Int
    let currentProtein: Int
    let goalProtein: Int
    let currentCarbs: Int
    let goalCarbs: Int
    let currentFat: Int
    let goalFat: Int
    
    private var progress: Double {
        guard goalCalories > 0 else { return 0 }
        return min(Double(currentCalories) / Double(goalCalories), 1.0)
    }
    
    // Calculate actual macro breakdown from consumed calories
    private var proteinCalories: Int { currentProtein * 4 }  // 4 cal per gram
    private var carbsCalories: Int { currentCarbs * 4 }      // 4 cal per gram  
    private var fatCalories: Int { currentFat * 9 }          // 9 cal per gram
    
    private var totalMacroCalories: Int {
        proteinCalories + carbsCalories + fatCalories
    }
    
    // Percentages of actual consumption (what portion of today's intake is each macro)
    private var proteinPercentage: Double {
        guard totalMacroCalories > 0 else { return 0 }
        return Double(proteinCalories) / Double(totalMacroCalories)
    }
    
    private var carbsPercentage: Double {
        guard totalMacroCalories > 0 else { return 0 }
        return Double(carbsCalories) / Double(totalMacroCalories)
    }
    
    private var fatPercentage: Double {
        guard totalMacroCalories > 0 else { return 0 }
        return Double(fatCalories) / Double(totalMacroCalories)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Elegant divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.white.opacity(0.2), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 8)
            
            // Two-ring system with detailed breakdown
            HStack(spacing: 24) {
                // Ring 1: Calorie Progress
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 8)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [.yellow, .orange, .red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.2, dampingFraction: 0.8), value: progress)
                        
                        VStack(spacing: 2) {
                            Text("\(Int(progress * 100))%")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("calories")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    Text("\(currentCalories)/\(goalCalories)")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Ring 2: Macronutrient Breakdown
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 8)
                            .frame(width: 100, height: 100)
                        
                        // Protein segment (0 to protein%)
                        Circle()
                            .trim(from: 0, to: proteinPercentage)
                            .stroke(
                                Color.cyan,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                        
                        // Carbs segment (protein% to protein% + carbs%)
                        Circle()
                            .trim(from: proteinPercentage, to: proteinPercentage + carbsPercentage)
                            .stroke(
                                Color.mint,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                        
                        // Fat segment (remaining portion)
                        Circle()
                            .trim(from: proteinPercentage + carbsPercentage, to: 1.0)
                            .stroke(
                                Color.pink,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 2) {
                            Text("Today's")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("intake")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: proteinPercentage)
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: carbsPercentage)
                    .animation(.spring(response: 1.2, dampingFraction: 0.8), value: fatPercentage)
                    
                    Text("breakdown")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 8)
            
            // Detailed macronutrient breakdown
            VStack(spacing: 12) {
                // Protein row
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.cyan)
                            .frame(width: 8, height: 8)
                        
                        Text("Protein")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(currentProtein)/\(goalProtein)g")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("\(Int(proteinPercentage * 100))% of today's intake")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.cyan.opacity(0.8))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.cyan.opacity(0.1))
                .cornerRadius(8)
                
                // Carbs row
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.mint)
                            .frame(width: 8, height: 8)
                        
                        Text("Carbs")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(currentCarbs)/\(goalCarbs)g")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("\(Int(carbsPercentage * 100))% of today's intake")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.mint.opacity(0.8))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.mint.opacity(0.1))
                .cornerRadius(8)
                
                // Fat row
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.pink)
                            .frame(width: 8, height: 8)
                        
                        Text("Fat")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(currentFat)/\(goalFat)g")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("\(Int(fatPercentage * 100))% of today's intake")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.pink.opacity(0.8))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    MainAppView()
}
