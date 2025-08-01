import SwiftUI

@MainActor
struct ModernAddFoodView: View {
    @Binding var selectedTab: ContentViewTab
    @EnvironmentObject var dataManager: FoodDataManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var aiService: AIService
    @State private var textInput = ""
    @State private var isLoading = false
    @State private var selectedTabString: String = "Home"
    
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
        default: return .home
        }
    }
    
    var body: some View {
        let _ = print("🔄 ModernAddFoodView body rendering")
        return VStack(spacing: 0) {
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
                Text("Add Food")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Track your meals with AI")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)
            
            // Chat area
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(chatManager.messages(for: .food)) { message in
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
                placeholder: "Describe what you ate...",
                quickActions: [
                    QuickAction(title: "Voice", icon: "mic.fill", color: .orange) {
                        // Handle voice input
                    },
                    QuickAction(title: "Camera", icon: "camera.fill", color: .blue) {
                        // Handle camera input
                    },
                    QuickAction(title: "Barcode", icon: "barcode", color: .green) {
                        // Handle barcode scan
                    }
                ],
                onSend: { message in
                    sendMessage()
                },
                onMicTap: {
                    // Handle mic tap
                },
                onCameraTap: {
                    // Handle camera tap
                }
            )
        }
        .onAppear {
            selectedTabString = tabToString(selectedTab)
        }
        .onChange(of: selectedTab) {
            selectedTabString = tabToString(selectedTab)
        }
    }
    
    private func sendMessage() {
        let trimmed = textInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        chatManager.addMessage(text: trimmed, sender: .user, to: .food)
        textInput = ""
        isLoading = true
        
        Task {
            do {
                let nutritionData = try await aiService.analyzeFood(input: trimmed, inputType: "text")
                
                await MainActor.run {
                    // Add nutrition data to food entries
                    for item in nutritionData {
                        dataManager.addEntry(FoodEntry(
                            userID: "localUser",
                            timestamp: Date(),
                            description: item.description,
                            calories: item.calories,
                            protein: item.protein,
                            carbs: item.carbs,
                            fat: item.fat,
                            inputMethod: .text
                        ))
                    }
                    
                    // Add confirmation message
                    let totalCalories = nutritionData.reduce(0) { $0 + $1.calories }
                    chatManager.addMessage(
                        text: "Added \(nutritionData.count) food item(s) with \(Int(totalCalories)) calories to your log!",
                        sender: .coach,
                        to: .food
                    )
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    chatManager.addMessage(
                        text: "Sorry, I couldn't analyze that food. Please try again.",
                        sender: .coach,
                        to: .food
                    )
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ModernAddFoodView(selectedTab: .constant(.home))
        .environmentObject(FoodDataManager())
        .environmentObject(ChatManager())
        .environmentObject(AIService())
}
