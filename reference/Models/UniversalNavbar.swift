//
//  UniversalNavbar.swift
//  Core Track by Lumora Labs
//
//  Created by AI Assistant on 24/7/2025.
//

import SwiftUI

// MARK: - Universal Navigation Bar
struct UniversalNavbar: View {
    // MARK: - Properties
    let title: String
    let subtitle: String?
    let currentTab: MainViewTab
    let onTabChange: (MainViewTab) -> Void
    let showBackButton: Bool
    let onBackPressed: (() -> Void)?
    let customActions: [NavAction]
    
    // MARK: - State
    @State private var showDropdown = false
    
    // MARK: - Initializer
    init(
        title: String,
        subtitle: String? = nil,
        currentTab: MainViewTab,
        onTabChange: @escaping (MainViewTab) -> Void,
        showBackButton: Bool = false,
        onBackPressed: (() -> Void)? = nil,
        customActions: [NavAction] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self.currentTab = currentTab
        self.onTabChange = onTabChange
        self.showBackButton = showBackButton
        self.onBackPressed = onBackPressed
        self.customActions = customActions
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Main navigation bar
            mainNavBar
                .onTapGesture {
                    if !showBackButton {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showDropdown.toggle()
                        }
                    }
                }
            
            // Dropdown for page navigation
            if showDropdown {
                navigationDropdown
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
    }
    
    // MARK: - Main Navigation Bar
    private var mainNavBar: some View {
        HStack(alignment: .center, spacing: 8) {
            // Left button
            leftButton
            
            Spacer()
            
            // Center content (tappable for dropdown)
            centerContent
            
            Spacer()
            
            // Right actions
            rightActions
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .padding(.top, 4) // Reduced padding for slimmer look
        .glassBackground(displayMode: .automatic)
    }
    
    // MARK: - Left Button
    private var leftButton: some View {
        Button(action: {
            if showBackButton {
                onBackPressed?()
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showDropdown.toggle()
                }
            }
        }) {
            HStack(spacing: 8) {
                ZStack {
                    // More glassy button with transparency
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.1))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .opacity(0.2)
                        )
                        .frame(width: 36, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                        )
                    
                    Image(systemName: showBackButton ? "chevron.left" : currentTab.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(showBackButton ? .white : currentTab.color)
                        .scaleEffect(showDropdown ? 1.05 : 1.0)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showDropdown)
        }
    }
    
    // MARK: - Center Content
    private var centerContent: some View {
        HStack(spacing: 8) {
            VStack(spacing: 1) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .multilineTextAlignment(.center)
            
            // Dropdown indicator (when not showing back button)
            if !showBackButton {
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .rotationEffect(.degrees(showDropdown ? 180 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showDropdown)
            }
        }
    }
    
    // MARK: - Right Actions
    private var rightActions: some View {
        HStack(spacing: 8) {
            ForEach(customActions, id: \.id) { action in
                Button(action: action.action) {
                    ZStack {
                        // iOS 26 Liquid Glass button
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 36, height: 36)
                            .glassEffect(shape: RoundedRectangle(cornerRadius: 20))
                        
                        Image(systemName: action.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(action.color)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            
            // Default notification button if no custom actions
            if customActions.isEmpty {
                Button(action: {
                    // Default action
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 36, height: 36)
                            .glassEffect(shape: RoundedRectangle(cornerRadius: 20))
                        
                        Image(systemName: "bell")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
        }
    }
    
    // MARK: - Navigation Dropdown
    private var navigationDropdown: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(MainViewTab.allCases, id: \.self) { tab in
                NavigationTabItem(
                    tab: tab,
                    isSelected: tab == currentTab,
                    action: {
                        onTabChange(tab)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showDropdown = false
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassEffect(shape: RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Navigation Tab Item
struct NavigationTabItem: View {
    let tab: MainViewTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with iOS 26 Liquid Glass background
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .frame(width: 32, height: 32)
                        .glassEffect(shape: RoundedRectangle(cornerRadius: 18))
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(tab.color)
                }
                
                // Title
                Text(tab.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .opacity(isSelected ? 1.0 : 0.8)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(tab.color)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? .white.opacity(0.08) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? .white.opacity(0.15) : .clear, lineWidth: 0.5)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Navigation Action Model
struct NavAction {
    let id = UUID()
    let icon: String
    let color: Color
    let action: () -> Void
}



// MARK: - MainViewTab Extensions
extension MainViewTab {
    var icon: String {
        switch self {
        case .home: return "leaf.fill"
        case .coach: return "brain.head.profile"
        case .voice: return "calendar.badge.plus"
        case .shop: return "cart.fill"
        case .analytics: return "chart.bar.fill"
        case .more: return "gearshape.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .green
        case .coach: return .purple
        case .voice: return .orange
        case .shop: return .blue
        case .analytics: return .cyan
        case .more: return .gray
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Core Track"
        case .coach: return "AI Coach"
        case .voice: return "Meal Planner"
        case .shop: return "Shopping"
        case .analytics: return "Analytics"
        case .more: return "Settings"
        }
    }
    
    static var allCases: [MainViewTab] {
        return [.home, .coach, .voice, .shop, .analytics, .more]
    }
}

// MARK: - Preview
#if DEBUG
struct UniversalNavbar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                UniversalNavbar(
                    title: "Core Track",
                    subtitle: "AI Food Coach",
                    currentTab: .home,
                    onTabChange: { _ in },
                    customActions: [
                        NavAction(icon: "plus", color: .white) { }
                    ]
                )
                
                Spacer()
                
                Text("Main Content Area")
                    .font(.title)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}
#endif

