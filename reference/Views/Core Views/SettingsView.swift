//
//  SettingsView.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 16/6/2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var selectedTab: ContentViewTab
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var dataManager: FoodDataManager
    @State private var selectedSection: SettingsSection = .account
    @State private var selectedTabString: String = "More"
    @State private var searchText: String = ""
    
    enum SettingsSection: String, CaseIterable {
        case account = "Account"
        case nutrition = "Nutrition"
        case notifications = "Notifications"
        case preferences = "Preferences"
        case data = "Data"
        
        var icon: String {
            switch self {
            case .account: return "person.circle"
            case .nutrition: return "target"
            case .notifications: return "bell"
            case .preferences: return "gear"
            case .data: return "externaldrive"
            }
        }
    }
    
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
        default: return .more
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
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Customize your experience")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 20)
            
            // Settings Content
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(SettingsSection.allCases, id: \.rawValue) { section in
                        settingsCard(for: section)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            // Input Bar for settings search
            LiquidGlassInputBar(
                text: $searchText,
                placeholder: "Search settings...",
                quickActions: [
                    QuickAction(title: "Account", icon: "person.circle", color: .blue) {
                        selectedSection = .account
                    },
                    QuickAction(title: "Export", icon: "square.and.arrow.up", color: .green) {
                        // Handle export action
                    },
                    QuickAction(title: "Help", icon: "questionmark.circle", color: .orange) {
                        // Handle help action
                    }
                ],
                onSend: { query in
                    // Handle settings search
                    searchSettings(query: query)
                },
                onMicTap: {
                    // Handle voice search for settings
                },
                onCameraTap: {
                    // Handle QR code settings import
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
    
    @ViewBuilder
    private func settingsCard(for section: SettingsSection) -> some View {
        Button {
            selectedSection = section
        } label: {
            HStack(spacing: 16) {
                Image(systemName: section.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(sectionDescription(for: section))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    private func sectionDescription(for section: SettingsSection) -> String {
        switch section {
        case .account: return "Profile, subscription, and account details"
        case .nutrition: return "Goals, macros, and dietary preferences"
        case .notifications: return "Alerts, reminders, and push notifications"
        case .preferences: return "App behavior and personalization"
        case .data: return "Export, import, and data management"
        }
    }
    
    private func searchSettings(query: String) {
        // Handle settings search functionality
        searchText = ""
    }
}

#Preview {
    SettingsView(selectedTab: .constant(.more))
        .environmentObject(NotificationManager.shared)
        .environmentObject(FoodDataManager())
}
