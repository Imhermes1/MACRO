//
//  LiquidGlassNavbarIcon.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 26/7/2025.
//

import SwiftUI

struct LiquidGlassNavbarIcon: View {
    @Binding var selectedTab: String
    let tabs: [String]
    let onTabSelected: (String) -> Void
    
    @State private var buttonScale: CGFloat = 1.0
    @State private var showDropdown = false
    
    private var selectedIconName: String {
        switch selectedTab {
        case "Home": return "house.fill"
        case "Search": return "magnifyingglass"
        case "Profile": return "person.fill"
        case "Settings": return "gearshape.fill"
        default: return "circle.fill"
        }
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            liquidGlassMenu
        } else {
            fallbackButton
        }
    }
    
    // MARK: - iOS 26+ Liquid Glass Menu
    @available(iOS 26.0, *)
    private var liquidGlassMenu: some View {
        Menu {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    selectedTab = tab
                    onTabSelected(tab)
                } label: {
                    HStack {
                        Image(systemName: iconName(for: tab))
                            .font(.system(size: 16, weight: .medium))
                        Text(tab)
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        if tab == selectedTab {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: selectedIconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .glassButtonStyleCompatible(scale: $buttonScale)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 10)
        .padding(.top, 10)
    }
    
    // MARK: - Fallback for iOS < 26
    private var fallbackButton: some View {
        VStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showDropdown.toggle()
                }
            } label: {
                Image(systemName: selectedIconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .glassButtonStyleCompatible(scale: $buttonScale)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            }
            .scaleEffect(buttonScale)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    buttonScale = 0.95
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        buttonScale = 1.0
                    }
                }
            }
            
            if showDropdown {
                fallbackDropdown
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
        .padding(.top, 10)
    }
    
    // MARK: - Fallback Dropdown
    private var fallbackDropdown: some View {
        VStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    selectedTab = tab
                    onTabSelected(tab)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDropdown = false
                    }
                } label: {
                    HStack {
                        Image(systemName: iconName(for: tab))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        Text(tab)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        Spacer()
                        if tab == selectedTab {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                
                if index < tabs.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.1))
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.white.opacity(0.1), radius: 6, x: 0, y: 0)
        .frame(minWidth: 180, maxWidth: 280)
        .padding(.top, 8)
    }
    
    // MARK: - Helper Methods
    private func iconName(for tab: String) -> String {
        switch tab {
        case "Home": return "house.fill"
        case "Search": return "magnifyingglass"
        case "Profile": return "person.fill"
        case "Settings": return "gearshape.fill"
        default: return "circle.fill"
        }
    }
}

// MARK: - Glass Button Style Extension
extension View {
    @ViewBuilder
    func glassButtonStyleCompatible(scale: Binding<CGFloat>) -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(GlassButtonStyle(scale: scale))
        }
    }
}

// MARK: - Fallback Glass Button Style
struct GlassButtonStyle: ButtonStyle {
    @Binding var scale: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    LiquidGlassNavbarIcon(
        selectedTab: .constant("Home"),
        tabs: ["Home", "Search", "Profile", "Settings"],
        onTabSelected: { tab in
            print("Selected: \(tab)")
        }
    )
    .preferredColorScheme(.dark)
}

