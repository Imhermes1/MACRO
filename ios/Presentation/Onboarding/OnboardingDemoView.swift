import SwiftUI

struct OnboardingDemoView: View {
    let onDismiss: () -> Void
    
    @State private var currentStep = 0
    @State private var showAnimation = false
    
    private let demoSteps = [
        DemoStep(
            icon: "mic.fill",
            title: "Voice Input Magic",
            description: "Just speak naturally: \"I had a turkey sandwich for lunch\" and we'll track the calories automatically!",
            color: .blue
        ),
        DemoStep(
            icon: "keyboard",
            title: "Type It Out",
            description: "Prefer typing? Just describe your meal: \"Large coffee with milk, 2 chocolate cookies\"",
            color: .green
        ),
        DemoStep(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Progress",
            description: "Watch your daily progress and stay on track with your nutrition goals",
            color: .orange
        ),
        DemoStep(
            icon: "target",
            title: "Reach Your Goals",
            description: "Set personalized calorie targets and let MACRO help you achieve them",
            color: .purple
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with blur effect
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        // App logo with glow
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.yellow.opacity(0.3),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .scaleEffect(showAnimation ? 1.1 : 0.9)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showAnimation)
                            
                            Image("LumoraLabsLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Welcome to MACRO")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Your intelligent nutrition companion")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    
                    // Demo steps
                    TabView(selection: $currentStep) {
                        ForEach(0..<demoSteps.count, id: \.self) { index in
                            DemoStepView(step: demoSteps[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 300)
                    
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<demoSteps.count, id: \.self) { index in
                            Circle()
                                .fill(currentStep == index ? Color.yellow : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentStep == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentStep)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        if currentStep < demoSteps.count - 1 {
                            // Next button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep += 1
                                }
                            }) {
                                HStack {
                                    Text("Next")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.yellow)
                                )
                            }
                            
                            // Skip button
                            Button("Skip Demo") {
                                onDismiss()
                            }
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                        } else {
                            // Get started button
                            Button(action: {
                                onDismiss()
                            }) {
                                HStack {
                                    Text("Get Started")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                }
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.yellow)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            showAnimation = true
        }
    }
}

// MARK: - Demo Step View
struct DemoStepView: View {
    let step: DemoStep
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon with animated background
            ZStack {
                Circle()
                    .fill(step.color.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(showContent ? 1.0 : 0.8)
                
                Image(systemName: step.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(step.color)
                    .scaleEffect(showContent ? 1.0 : 0.5)
            }
            
            // Text content
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1.0 : 0.0)
                
                Text(step.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(showContent ? 1.0 : 0.0)
            }
            .padding(.horizontal, 20)
        }
        .animation(.easeOut(duration: 0.6), value: showContent)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showContent = true
            }
        }
        .onDisappear {
            showContent = false
        }
    }
}

// MARK: - Demo Step Model
struct DemoStep {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

#Preview {
    OnboardingDemoView {
        print("Demo dismissed")
    }
}
