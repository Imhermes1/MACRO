//
//  CoreTrackApp.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 11/6/2025.
//

import SwiftUI

@main
struct CoreTrackApp: App {
    // MARK: - Environment Objects (always needed)
    @StateObject private var foodDataManager = FoodDataManager()
    @StateObject private var chatManager = ChatManager()
    @StateObject private var userManager = UserManager()
    @StateObject private var nutritionService = NutritionService()
    @StateObject private var aiService = AIService()
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var weatherManager = WeatherManager.shared
    
    // MARK: - Lazy Managers (only loaded when accessed)
    // ServiceManager will be lazily loaded when needed to prevent memory issues
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(foodDataManager)
                .environmentObject(chatManager)
                .environmentObject(userManager)
                .environmentObject(weatherManager)
                .environmentObject(ServiceManager.shared)

                .onAppear {
                    // Initialize weather and location services
                    weatherManager.requestLocation()
                    
                    // Set up initial greeting if this is the first time opening the app
                    if chatManager.messages(for: .food).isEmpty {
                        let greeting = weatherManager.generateGreeting(userName: foodDataManager.currentUserName)
                        chatManager.addMessage(text: greeting, sender: .coach, to: .food)
                    }
                    
                    // Request notification permissions
                    notificationManager.requestAuthorization()
                    
                    // iOS 26 Fix: Don't preload SpeechManager during startup
                    // Let it initialize lazily when actually needed to prevent crashes
                    print("🚀 CoreTrack: App startup completed - SpeechManager will load when needed")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FoodDataManager())
        .environmentObject(ChatManager())
        .environmentObject(UserManager())
        .environmentObject(NutritionService())
        .environmentObject(AIService())
        .environmentObject(NotificationManager.shared)
        .environmentObject(WeatherManager.shared)
        .environmentObject(ServiceManager.shared)
}
