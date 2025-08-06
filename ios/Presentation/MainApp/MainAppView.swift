import SwiftUI
import Foundation
import WeatherKit
import Combine 

struct MainAppView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showOnboardingDemo = false
    @State private var todaysCalories = 0
    @State private var calorieGoal = 2000
    @State private var isProgressExpanded = false
    @State private var showAnalytics = false
    
    // Smart welcome system properties
    @State private var showWelcomeMessage = false
    @State private var welcomeMessage = ""
    private let weatherManager = WeatherManager.shared
    
    var body: some View {
        ZStack {
            UniversalBackground()
            
            VStack(spacing: 0) {
                // Main content area
                ScrollView {
                    VStack(spacing: 20) {
                        // Add top padding for navigation bar
                        Spacer()
                            .frame(height: 130) // Space for navigation bar + a bit more
                        
                        // Chat view with proper positioning
                        NutritionChatView()
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 100) // Space for floating input bar
                }
                .background(Color.clear)
                .zIndex(0) // Base layer for main content
                
                Spacer()
            }
            
            // NavigationBar sits on top of all content
            VStack {
                NavigationBar(
                    showTabDropdown: true,
                    showProfileButton: true,
                    profileAction: {
                        // Navigate to settings/profile
                    },
                    tabNavigationAction: { tabTitle in
                        if tabTitle == "Analytics" {
                            showAnalytics = true
                        }
                    }
                )
                .padding(EdgeInsets(top: 44, leading: 16, bottom: 0, trailing: 16))
                
                Spacer()
            }
            .zIndex(3) // Navigation layer
            
            // Floating input bar at bottom using FloatingInputBar component
            VStack {
                Spacer()
                FloatingInputBar()
                    .padding(.bottom, 34) // Safe area bottom
            }
            .zIndex(1) // Floating input layer
            
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
            .zIndex(2) // Daily progress dropdown base
            
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
                .zIndex(2) // Daily progress expanded content
            }
        }
        .ignoresSafeArea(.all)
        .onAppear {
            setupSmartWelcome()
            // Record user activity when main app appears
            UserActivityService.shared.recordActivity()
        }
        .sheet(isPresented: $showOnboardingDemo) {
            // OnboardingDemoView - temporarily commented out
            Text("Demo View Placeholder")
                .onTapGesture {
                    UserDefaults.standard.set(true, forKey: "has_seen_app_demo")
                    showOnboardingDemo = false
                }
        }
        .sheet(isPresented: $showAnalytics) {
            ProgressAnalyticsView()
        }
    }
    
    // MARK: - Smart Welcome System with WeatherManager
    
    /**
     * Enhanced welcome system that combines usage patterns with weather/location context
     */
    private func setupSmartWelcome() {
        // Check user preferences first
        if UserDefaults.standard.bool(forKey: "disable_smart_welcome") {
            return
        }
        
        let lastLoginDate = UserDefaults.standard.object(forKey: "last_login_date") as? Date
        let loginCount = UserDefaults.standard.integer(forKey: "total_login_count")
        
        // Update login stats
        UserDefaults.standard.set(Date(), forKey: "last_login_date")
        UserDefaults.standard.set(loginCount + 1, forKey: "total_login_count")
        
        // Check if we should show welcome based on usage patterns
        if shouldShowWelcome(lastLogin: lastLoginDate, loginCount: loginCount + 1) {
            // Request location for weather context
            weatherManager.requestLocation()
            
            // Generate contextual greeting
            generateContextualWelcome(loginCount: loginCount + 1, lastLogin: lastLoginDate)
            
            // Show welcome with delay for smooth entrance
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showWelcomeMessage = true
                }
                
                // Auto-dismiss after 6 seconds (longer for rich content)
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showWelcomeMessage = false
                    }
                }
            }
        }
    }
    
    /**
     * Determines if we should show welcome based on usage patterns
     */
    private func shouldShowWelcome(lastLogin: Date?, loginCount: Int) -> Bool {
        // Skip for very new users (they get full welcome screen)
        if loginCount <= 3 {
            return false
        }
        
        // Skip if already shown greeting this session
        if weatherManager.hasLoadedGreetingThisSession {
            return false
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Always show after long absence (7+ days)
        if let lastLogin = lastLogin {
            let daysSinceLastLogin = calendar.dateComponents([.day], from: lastLogin, to: now).day ?? 0
            if daysSinceLastLogin >= 7 {
                return true
            }
            
            // Show after weekend break (2+ days)
            if daysSinceLastLogin >= 2 {
                return true
            }
        }
        
        // Show based on time patterns (morning sessions, meal times)
        let hour = calendar.component(.hour, from: now)
        
        // Morning greeting (6-11 AM)
        if hour >= 6 && hour < 11 {
            return true
        }
        
        // Meal time greetings
        if hour >= 11 && hour < 15 || hour >= 17 && hour < 21 {
            return true
        }
        
        // Show 30% of the time for other sessions (to avoid being too chatty)
        return Double.random(in: 0...1) < 0.3
    }
    
    /**
     * Generates contextual welcome message using WeatherManager
     */
    private func generateContextualWelcome(loginCount: Int, lastLogin: Date?) {
        // Get name from profile first (if exists), then auth manager, then fallback to "there"
        let profileRepo = UserProfileRepository()
        let userProfile = profileRepo.loadProfile()
        let userName = userProfile?.firstName ?? (authManager.userFirstName.isEmpty ? "there" : authManager.userFirstName)
        
        // Check for special usage patterns first
        if let lastLogin = lastLogin {
            let daysSinceLastLogin = Calendar.current.dateComponents([.day], from: lastLogin, to: Date()).day ?? 0
            
            if daysSinceLastLogin >= 7 {
                welcomeMessage = "Welcome back, \(userName)! 🎉 It's been a while. " + weatherManager.weatherBasedRemark()
                weatherManager.hasLoadedGreetingThisSession = true
                return
            }
            
            if daysSinceLastLogin >= 2 {
                welcomeMessage = "Hey \(userName)! Ready to get back on track? " + weatherManager.weatherBasedRemark()
                weatherManager.hasLoadedGreetingThisSession = true
                return
            }
        }
        
        // Use WeatherManager's sophisticated greeting system
        welcomeMessage = weatherManager.generateGreeting(userName: userName)
        weatherManager.hasLoadedGreetingThisSession = true
    }
    
    /**
     * Returns appropriate icon based on weather and time context
     */
    private func getWelcomeIcon() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Check weather conditions first
        if let weather = weatherManager.currentWeather {
            switch weather.currentWeather.condition {
            case .clear:
                return hour >= 6 && hour < 18 ? "sun.max.fill" : "moon.stars.fill"
            case .cloudy, .mostlyCloudy, .partlyCloudy:
                return "cloud.fill"
            case .rain, .drizzle:
                return "cloud.rain.fill"
            case .thunderstorms:
                return "cloud.bolt.rain.fill"
            case .snow, .flurries, .blizzard:
                return "cloud.snow.fill"
            case .haze:
                return "cloud.fog.fill"
            default:
                break
            }
        }
        
        // Fallback to time-based icons
        switch hour {
        case 5..<12:
            return "sunrise.fill"
        case 12..<17:
            return "sun.max.fill"
        case 17..<20:
            return "sunset.fill"
        default:
            return "moon.stars.fill"
        }
    }
    
    /**
     * Allow users to disable smart welcome (call this from settings)
     */
    static func disableSmartWelcome() {
        UserDefaults.standard.set(true, forKey: "disable_smart_welcome")
    }
    
    /**
     * Allow users to re-enable smart welcome (call this from settings)
     */
    static func enableSmartWelcome() {
        UserDefaults.standard.set(false, forKey: "disable_smart_welcome")
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
    
    // MARK: - AI Analysis Methods (DUPLICATE - COMMENTED OUT)
    
    /*
     * These methods have been moved to dedicated food processing services
     * MainAppView should only handle UI hosting, not food analysis logic
     */
}

// MARK: - AI Analysis Card Component (Moved to separate file)
// These UI components should be in their own files

// MARK: - Error Card Component (Moved to separate file)
// These UI components should be in their own files

// End of MainAppView struct

#Preview {
    MainAppView()
}

