import SwiftUI
import AVFoundation

@MainActor
struct VoiceMealPlannerView: View {
    @Binding var selectedTab: ContentViewTab
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var chatManager: ChatManager

    // MARK: - State
    @State private var textInput = ""
    @State private var goals = ""
    @State private var preferences = ""
    @State private var restrictions = ""
    @State private var timeframe = "1 week"
    @State private var generatedPlan = ""
    @State private var isGenerating = false
    @State private var showingPlan = false
    @State private var selectedTabString: String = "Voice"

    // MARK: - Constants
    let timeframeOptions = ["3 days", "1 week", "2 weeks", "1 month"]
    
    // Map ContentViewTab to String for LiquidGlassNavbarIcon
    private func tabToString(_ tab: ContentViewTab) -> String {
        return tab.title
    }
    
    private func stringToTab(_ string: String) -> ContentViewTab {
        switch string {
        case "Home": return .home
        case "Coach": return .coach
        case "Voice": return .voice
        case "Shop": return .shop
        case "Analytics": return .analytics
        case "More": return .more
        default: return .voice
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation
            LiquidGlassNavbarIcon(
                selectedTab: $selectedTabString,
                tabs: ["Home", "Coach", "Voice", "Shop", "Analytics", "More"],
                onTabSelected: { tabString in
                    selectedTabString = tabString
                    selectedTab = stringToTab(tabString)
                }
            )
            .zIndex(1000)
            
            // Header
            VStack(spacing: 8) {
                Text("Meal Planner")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("AI-powered meal planning")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    inputForm
                    generateButton
                    generatedPlanView
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            // Input Bar for meal planning
            LiquidGlassInputBar(
                text: $textInput,
                placeholder: "Ask about meal planning...",
                quickActions: [
                    QuickAction(title: "Generate", icon: "wand.and.stars", color: .purple) {
                        generateMealPlan()
                    },
                    QuickAction(title: "Preferences", icon: "heart.fill", color: .red) {
                        // Handle preferences quick action
                    },
                    QuickAction(title: "Calendar", icon: "calendar", color: .blue) {
                        // Handle calendar quick action
                    }
                ],
                onSend: { message in
                    handleMealPlanRequest(message)
                },
                onMicTap: {
                    // Handle voice input for meal planning
                },
                onCameraTap: {
                    // Handle camera for meal photos
                }
            )
        }
        .onAppear {
            selectedTabString = tabToString(selectedTab)
        }
        .onChange(of: selectedTab) { _, newTab in
            selectedTabString = tabToString(newTab)
        }
    }
    
    // MARK: - Views
    @ViewBuilder
    private var inputForm: some View {
        VStack(spacing: 16) {
            inputField(title: "Goals", text: $goals, placeholder: "e.g., Lose weight, gain muscle...")
            inputField(title: "Preferences", text: $preferences, placeholder: "e.g., Mediterranean, low-carb...")
            inputField(title: "Restrictions", text: $restrictions, placeholder: "e.g., Vegetarian, gluten-free...")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Timeframe")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Picker("Timeframe", selection: $timeframe) {
                    ForEach(timeframeOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    @ViewBuilder
    private func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .font(.body)
                .foregroundColor(.primary)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        }
    }
    
    @ViewBuilder
    private var generateButton: some View {
        Button {
            generateMealPlan()
        } label: {
            HStack {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(isGenerating ? "Generating..." : "Generate Meal Plan")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .disabled(isGenerating || goals.isEmpty)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .opacity(isGenerating || goals.isEmpty ? 0.6 : 1.0)
        )
    }
    
    @ViewBuilder
    private var generatedPlanView: some View {
        if !generatedPlan.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Meal Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(generatedPlan)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Methods
    private func generateMealPlan() {
        guard !goals.isEmpty else { return }
        isGenerating = true
        
        // Map preferences string to CuisineType(s)
        let cuisineTypes: [CuisineType] = preferences.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .compactMap { input in
                CuisineType.allCases.first { $0.rawValue.lowercased().contains(input) }
            }
        let selectedCuisineTypes = cuisineTypes.isEmpty ? [.mediterranean] : cuisineTypes
        
        // Map timeframe to CookingTime
        let cookingTime: CookingTime
        switch timeframe.lowercased() {
        case _ where timeframe.contains("day"): cookingTime = .quick
        case _ where timeframe.contains("week"): cookingTime = .medium
        case _ where timeframe.contains("month"): cookingTime = .slow
        default: cookingTime = .medium
        }
        
        // Use default servings and budget
        let mealPreferences = MealPreferences(
            cuisine: selectedCuisineTypes,
            cookingTime: cookingTime,
            servings: 2,
            budget: .moderate
        )
        
        Task {
            do {
                let mealPlan = try await aiService.generateMealPlan(preferences: mealPreferences)
                await MainActor.run {
                    self.generatedPlan = mealPlan.description
                    self.isGenerating = false
                    self.showingPlan = true
                }
            } catch {
                await MainActor.run {
                    self.generatedPlan = "Sorry, I couldn't generate a meal plan right now. Please try again."
                    self.isGenerating = false
                }
            }
        }
    }
    
    private func handleMealPlanRequest(_ message: String) {
        // Handle text input for meal planning requests
        textInput = ""
        
        // Add to chat or process the request
        chatManager.addMessage(text: message, sender: .user, to: .food)
        
        Task {
            do {
                let mealPreferences = MealPreferences(
                    cuisine: [.mediterranean], // Or parse from message if possible
                    cookingTime: .medium,
                    servings: 2,
                    budget: .moderate
                )
                let response = try await aiService.generateMealPlan(preferences: mealPreferences)
                await MainActor.run {
                    chatManager.addMessage(text: response.description, sender: .coach, to: .food)
                }
            } catch {
                await MainActor.run {
                    chatManager.addMessage(
                        text: "I'm having trouble with that request. Please try again.",
                        sender: .coach,
                        to: .food
                    )
                }
            }
        }
    }
}

