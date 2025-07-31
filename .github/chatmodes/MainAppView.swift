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
                // Add safe area padding for the TransparentTopBar
                Spacer()
                    .frame(height: 100) // Account for status bar + TransparentTopBar height
                
                // Dropdown Progress Bar
                DropdownProgressBar(
                    currentCalories: todaysCalories,
                    goalCalories: calorieGoal,
                    isExpanded: $isProgressExpanded
                )
                .zIndex(1) // Ensure it sits on top
                
                // Main content area
                ScrollView {
                    VStack(spacing: 20) {
                        // Add top padding to account for TransparentTopBar and dropdown
                        Spacer()
                            .frame(height: 80) // Increased to account for floating top bar
                        
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
            
            // TransparentTopBar sits on top of all content (from Components/TransparentTopBar.swift)
            VStack {
                TransparentTopBar(
                    showRightButton: true,
                    rightAction: {
                        // Navigate to settings/profile
                        print("Navigate to settings")
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
    
    private var progress: Double {
        guard goalCalories > 0 else { return 0 }
        return min(Double(currentCalories) / Double(goalCalories), 1.0)
    }
    
    private var remainingCalories: Int {
        max(goalCalories - currentCalories, 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Collapsed header bar
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Progress summary
                    HStack(spacing: 8) {
                        // Mini progress circle
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                                )
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(-90))
                        }
                        
                        Text("Today's Progress")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Current stats
                    HStack(spacing: 8) {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text("\(currentCalories) / \(goalCalories)")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("calories")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // Chevron indicator
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded content
            if isExpanded {
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
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 24) {
                        // Large progress circle with Apple-style animation
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
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("complete")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Detailed stats with Apple-style cards
                        VStack(spacing: 12) {
                            // Consumed card
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(.green)
                                            .frame(width: 8, height: 8)
                                        
                                        Text("Consumed")
                                            .font(.system(.caption, design: .rounded, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Text("\(currentCalories)")
                                        .font(.system(.title3, design: .rounded, weight: .bold))
                                        .foregroundColor(.white)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.6), value: currentCalories)
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            
                            // Remaining card
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(.yellow)
                                            .frame(width: 8, height: 8)
                                        
                                        Text("Remaining")
                                            .font(.system(.caption, design: .rounded, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Text("\(remainingCalories)")
                                        .font(.system(.title3, design: .rounded, weight: .bold))
                                        .foregroundColor(.yellow)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.6), value: remainingCalories)
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    
                    // Progress bar with smooth animation
                    VStack(spacing: 8) {
                        HStack {
                            Text("Daily Goal Progress")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.15))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 6)
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
                    .padding(.bottom, 20)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)).combined(with: .offset(y: -10)),
                    removal: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)).combined(with: .offset(y: -10))
                ))
            }
        }
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
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: isExpanded ? 20 : 12,
                bottomTrailingRadius: isExpanded ? 20 : 12,
                topTrailingRadius: 0
            )
        )
        .shadow(
            color: .black.opacity(isExpanded ? 0.15 : 0.08),
            radius: isExpanded ? 12 : 6,
            x: 0,
            y: isExpanded ? 6 : 3
        )
        .animation(.spring(response: 0.8, dampingFraction: 0.9), value: isExpanded)
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
