import SwiftUI

struct AICoachView: View {
    @Binding var selectedTab: ContentViewTab
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var foodDataManager: FoodDataManager
    @State private var textInput: String = ""
    @State private var showImagePicker: Bool = false
    @State private var selectedTabString: String = "Coach"
    @State private var isLoading = false
    
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
        default: return .coach
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
                Text("AI Coach")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your personal nutrition expert")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)
            
            // Chat area
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(chatManager.messages(for: .coach)) { message in
                        ChatBubbleView(message: message)
                    }
                    if isLoading {
                        ChatTypingIndicator()
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()
            
            // Input Bar
            LiquidGlassInputBar(
                text: $textInput,
                placeholder: "Ask your AI coach anything...",
                quickActions: [
                    QuickAction(title: "Goals", icon: "target", color: .green) {
                        // Handle goals quick action
                    },
                    QuickAction(title: "Progress", icon: "chart.line.uptrend.xyaxis", color: .blue) {
                        // Handle progress quick action
                    },
                    QuickAction(title: "Tips", icon: "lightbulb.fill", color: .yellow) {
                        // Handle tips quick action
                    }
                ],
                onSend: { message in
                    sendMessage()
                },
                onMicTap: {
                    handleMicButton()
                },
                onCameraTap: {
                    showImagePicker = true
                }
            )
        }
        .onAppear {
            selectedTabString = tabToString(selectedTab)
        }
        .onChange(of: selectedTab) { _, newTab in
            selectedTabString = tabToString(newTab)
        }
        .sheet(isPresented: $showImagePicker) {
            // Image picker sheet
        }
    }

    func sendMessage() {
        let trimmed = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        chatManager.addMessage(text: trimmed, sender: .user, to: .coach)
        textInput = ""
        isLoading = true
        
        // Build ChatContext with placeholder values - replace with real user data when available
        let context = ChatContext(
            userProfile: UserProfile(
                age: 30, // TODO: Replace with real value if available
                weight: 70, // TODO: Replace with real value
                height: 175, // TODO: Replace with real value
                activityLevel: .moderatelyActive, // TODO: Replace with real value
                dietaryRestrictions: [],
                healthConditions: []
            ),
            conversationHistory: chatManager.messages(for: .coach),
            currentGoals: NutritionGoals(
                calorieGoal: notificationManager.getCalorieGoal(),
                proteinGoal: 150, // TODO: Replace with real value if available
                carbGoal: 250, // TODO: Replace with real value
                fatGoal: 65, // TODO: Replace with real value
                weightGoal: .maintain // TODO: Replace with real value
            )
        )
        
        Task {
            do {
                let response = try await aiService.sendMessage(trimmed, context: context)
                await MainActor.run {
                    chatManager.addMessage(text: response, sender: .coach, to: .coach)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    chatManager.addMessage(
                        text: "I'm having trouble responding right now. Please try again.",
                        sender: .coach,
                        to: .coach
                    )
                    isLoading = false
                }
            }
        }
    }

    func handleMicButton() {
        // Handle voice input for AI coach
    }
}
