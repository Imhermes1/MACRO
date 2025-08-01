//
//  AppPreferencesView.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 16/6/2025.
//

import SwiftUI

struct AppPreferencesView: View {
    @State private var darkModeEnabled = false
    @State private var hapticFeedback = true
    @State private var soundEnabled = true
    @State private var showingFoodDeliverySheet = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("App Preferences")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Customise your app experience")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Appearance
            VStack(spacing: 16) {
                Text("Appearance")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dark Mode")
                            .foregroundColor(.white)
                            .font(.body)
                        Text("Use dark theme throughout the app")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $darkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Feedback
            VStack(spacing: 16) {
                Text("Feedback")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Haptic Feedback")
                            .foregroundColor(.white)
                            .font(.body)
                        Text("Vibrate on interactions")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $hapticFeedback)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sound Effects")
                            .foregroundColor(.white)
                            .font(.body)
                        Text("Play sounds for actions")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $soundEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Food Services
            VStack(spacing: 16) {
                Text("Food Services")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                SettingsButton(
                    title: "Food Delivery",
                    subtitle: "Connect with delivery services",
                    icon: "car.fill",
                    action: { showingFoodDeliverySheet = true }
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .sheet(isPresented: $showingFoodDeliverySheet) {
            FoodDeliveryView()
        }
    }
}

struct FoodDeliveryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Food Delivery Services")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Connect your favourite delivery services to get personalised recommendations and easy ordering.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    deliveryServiceButton("Uber Eats", icon: "car.fill", color: .black)
                    deliveryServiceButton("Menulog", icon: "bag.fill", color: .orange)
                    deliveryServiceButton("Deliveroo", icon: "bicycle", color: .blue)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func deliveryServiceButton(_ title: String, icon: String, color: Color) -> some View {
        Button(action: {
            // TODO: Implement service connection
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 32)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AppPreferencesView()
} 