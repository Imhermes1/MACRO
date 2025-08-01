//  ContentView.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 11/6/2025.
//
import SwiftUI

// MARK: - Navigation Action Model
struct NavAction {
    let icon: String
    let color: Color
    let action: () -> Void
}

// MARK: – Glow Overlay for Recording / Response
struct GlowOverlay: View {
    @State private var angle: Double = 0
    let audioLevel: Float
    var isActive: Bool = true

    var body: some View {
        let colorStops = [
            Color(red: 1.0, green: 0.1, blue: 0.1),
            Color(red: 0.8, green: 0.0, blue: 0.8),
            Color(red: 1.0, green: 0.0, blue: 0.0),
            Color(red: 0.6, green: 0.0, blue: 1.0),
            Color(red: 1.0, green: 0.1, blue: 0.1),
        ]
        let clampedLevel = min(max(audioLevel, 0.01), 0.3)
        let lineWidth = 25 + clampedLevel * 80
        let blurRadius = 20 + clampedLevel * 40
        let baseOpacity: Double = isActive ? 1.0 : 0.0

        return RoundedRectangle(cornerRadius: 0)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: colorStops),
                    center: .center,
                    angle: .degrees(angle)
                ),
                lineWidth: CGFloat(lineWidth)
            )
            .blur(radius: CGFloat(blurRadius))
            .opacity(baseOpacity)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
    }
}

// MARK: - Tab Enum
enum ContentViewTab: String, CaseIterable, Identifiable {
    case home = "home"
    case coach = "coach"
    case voice = "voice"
    case shop = "shop"
    case analytics = "analytics"
    case more = "more"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .coach: return "Coach"
        case .voice: return "Voice"
        case .shop: return "Shop"
        case .analytics: return "Analytics"
        case .more: return "More"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .coach: return "brain.head.profile"
        case .voice: return "calendar.badge.plus"
        case .shop: return "cart.badge.plus"
        case .analytics: return "chart.bar.xaxis"
        case .more: return "gear"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .blue
        case .coach: return .green
        case .voice: return .orange
        case .shop: return .red
        case .analytics: return .indigo
        case .more: return .purple
        }
    }
}

// MARK: – Main Content View
@MainActor
struct ContentView: View {
    @EnvironmentObject var foodDataManager: FoodDataManager
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var nutritionService: NutritionService
    @EnvironmentObject var aiService: AIService
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var weatherManager: WeatherManager
    @EnvironmentObject var serviceManager: ServiceManager
    
    @State private var selectedTab: ContentViewTab = .home

    var body: some View {
        ZStack {
            // Background only - ContentView's single responsibility
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Each view handles its own navigation and input
            Group {
                switch selectedTab {
                case .home:
                    ModernAddFoodView(selectedTab: $selectedTab)
                case .coach:
                    CoachTabContentView(onTabChange: { tab in
                        selectedTab = tab
                    })
                case .voice:
                    VoiceMealPlannerView(selectedTab: $selectedTab)
                case .shop:
                    SmartGroceryView(selectedTab: $selectedTab)
                case .analytics:
                    AnalyticsView(selectedTab: $selectedTab)
                case .more:
                    SettingsView(selectedTab: $selectedTab)
                }
            }
        }
    }
}

// MARK: – Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

