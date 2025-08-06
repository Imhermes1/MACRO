//
//  NutritionChatView.swift
//  Macro
//
//  Modern Australian nutrition chat interface with glass design
//
//  Created by Luke Fornieri on 5/8/2025.
//

import SwiftUI
import Combine

/// Modern nutrition chat interface with input bar and glass design
struct NutritionChatView: View {
    
    @State private var messages: [SimpleMessage] = []
    @State private var isProcessing: Bool = false
    @State private var isInitialLoading: Bool = true
    @StateObject private var aiWelcomeService = AIWelcomeService.shared
    
    var body: some View {
        // Chat Messages Area - No input bar since it's handled by MainAppView's FloatingInputBar
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        ModernMessageRow(message: message)
                            .id(message.id)
                    }
                    
                    // Typing indicator when processing OR initial loading
                    if isProcessing || isInitialLoading {
                        ModernTypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    if let lastID = messages.last?.id {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    } else {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
            .onChange(of: isProcessing) { _, newValue in
                if newValue || isInitialLoading {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
        .onAppear {
            setupWelcomeMessage()
            setupNotificationListener()
        }
        .onDisappear {
            removeNotificationListener()
        }
    }
    
    // MARK: - Notification Communication
    
    private func setupNotificationListener() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NutritionInputReceived"),
            object: nil,
            queue: .main
        ) { notification in
            if let text = notification.object as? String {
                processFood(text: text)
            }
        }
    }
    
    private func removeNotificationListener() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("NutritionInputReceived"),
            object: nil
        )
    }
    
    // MARK: - Methods
    
    private func setupWelcomeMessage() {
        let userName = "User" // Will be connected to AuthManager later
        
        // Show initial loading animation
        isInitialLoading = true
        
        Task {
            // Add a slight delay to show the loading animation
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            let welcomeMessage = await aiWelcomeService.generateWelcomeMessage(for: userName)
            
            await MainActor.run {
                // Hide loading animation
                withAnimation(.easeInOut(duration: 0.3)) {
                    isInitialLoading = false
                }
                
                // Add welcome message after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    messages.append(SimpleMessage(content: welcomeMessage, isUser: false))
                }
            }
        }
    }
    
    func processFood(text: String) {
        // Add user message
        messages.append(SimpleMessage(content: text, isUser: true))
        
        // Start processing animation immediately
        withAnimation(.easeInOut(duration: 0.3)) {
            isProcessing = true
        }
        print("🔄 Started typing animation - isProcessing: \(isProcessing)")
        
        // Simulate processing with realistic delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isProcessing = false
            }
            print("✅ Stopped typing animation - isProcessing: \(isProcessing)")
            
            // Generate intelligent response based on input
            let response = generateIntelligentResponse(for: text)
            messages.append(SimpleMessage(content: response, isUser: false))
        }
    }
    
    private func generateIntelligentResponse(for input: String) -> String {
        let lowercaseInput = input.lowercased()
        
        // Check if input contains food-related keywords
        let foodKeywords = [
            // Meals
            "breakfast", "lunch", "dinner", "snack", "meal", "ate", "eating", "food",
            // Common foods
            "apple", "banana", "chicken", "rice", "bread", "egg", "milk", "cheese", "pizza", "sandwich",
            "salad", "pasta", "beef", "fish", "yogurt", "cereal", "oats", "nuts", "avocado", "tomato",
            "carrot", "broccoli", "potato", "onion", "garlic", "spinach", "lettuce", "cucumber",
            // Cooking methods
            "grilled", "baked", "fried", "boiled", "steamed", "roasted", "cooked",
            // Quantities/measurements
            "cup", "slice", "piece", "serving", "bowl", "plate", "grams", "ounces", "tbsp", "tsp",
            // Drinks
            "coffee", "tea", "water", "juice", "smoothie", "shake", "beer", "wine", "soda"
        ]
        
        let isFoodRelated = foodKeywords.contains { keyword in
            lowercaseInput.contains(keyword)
        }
        
        // Check for common greetings and non-food messages
        let nonFoodKeywords = [
            "hello", "hi", "hey", "good morning", "good afternoon", "good evening",
            "how are you", "what's up", "thanks", "thank you", "bye", "goodbye",
            "help", "what can you do", "who are you", "test", "testing"
        ]
        
        let isNonFoodMessage = nonFoodKeywords.contains { keyword in
            lowercaseInput.contains(keyword)
        }
        
        // If it's clearly not food-related, prompt for food input
        if isNonFoodMessage || (!isFoodRelated && input.split(separator: " ").count < 3) {
            let friendlyPrompts = [
                "G'day! I'm Macro, here to help you track your nutrition. What have you eaten today? 🍎",
                "Hey there! I'm Macro, ready to log some food? Tell me about your last meal! 🥗",
                "Hi! I'm Macro, your nutrition tracking assistant. What delicious food can I help you log? 🍽️",
                "Hello! I'm Macro and I'd love to help you track your meals. What have you had to eat recently? 🥑",
                "Hey! I'm Macro, let's get your nutrition on track. What food would you like to add to your log? 🥙"
            ]
            return friendlyPrompts.randomElement() ?? friendlyPrompts[0]
        }
        
        // If it contains food keywords, process as food
        if lowercaseInput.contains("breakfast") {
            return "Great choice for breakfast! I've logged that for you. Consider adding some protein if you haven't already."
        } else if lowercaseInput.contains("lunch") {
            return "Perfect lunch option! I've tracked your meal. How are you feeling energy-wise?"
        } else if lowercaseInput.contains("dinner") {
            return "Excellent dinner choice! Meal logged successfully. This should help you reach your daily goals."
        } else if lowercaseInput.contains("snack") {
            return "Smart snacking! I've added this to your log. You're doing well with portion control."
        } else {
            return "I've successfully logged '\(input)' to your nutrition tracker. Keep up the great work with your healthy choices!"
        }
    }
}

// MARK: - Modern Message Components

struct ModernMessageRow: View {
    let message: SimpleMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                userBubble
            } else {
                assistantBubble
                Spacer()
            }
        }
    }
    
    private var userBubble: some View {
        Text(message.content)
            .font(.system(.body, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .frame(maxWidth: 280, alignment: .trailing)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var assistantBubble: some View {
        Text(message.content)
            .font(.system(.body, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .frame(maxWidth: 280, alignment: .leading)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Modern Typing Indicator

struct ModernTypingIndicator: View {
    @State private var bounce1 = false
    @State private var bounce2 = false
    @State private var bounce3 = false
    
    var body: some View {
        HStack {
            HStack(spacing: 4) { // Reduced from 8 to 4
                Circle()
                    .fill(Color.cyan.opacity(0.8))
                    .frame(width: 6, height: 6) // Reduced from 10 to 6
                    .scaleEffect(bounce1 ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: bounce1)
                
                Circle()
                    .fill(Color.mint.opacity(0.8))
                    .frame(width: 6, height: 6) // Reduced from 10 to 6
                    .scaleEffect(bounce2 ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.2), value: bounce2)
                
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 6, height: 6) // Reduced from 10 to 6
                    .scaleEffect(bounce3 ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(0.4), value: bounce3)
            }
            .padding(.horizontal, 12) // Reduced from 20 to 12
            .padding(.vertical, 8) // Reduced from 14 to 8
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)) // Reduced from 20 to 16
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous) // Reduced from 20 to 16
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
            .onAppear {
                bounce1 = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    bounce2 = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    bounce3 = true
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Supporting Types

struct SimpleMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

// MARK: - Preview

struct NutritionChatView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Use your app's background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.15, blue: 0.25),
                    Color(red: 0.15, green: 0.25, blue: 0.35)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            NutritionChatView()
        }
        .preferredColorScheme(.dark)
    }
}

