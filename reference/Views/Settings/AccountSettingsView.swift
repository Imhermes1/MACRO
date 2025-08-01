//
//  AccountSettingsView.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 16/6/2025.
//

import SwiftUI

struct AccountSettingsView: View {
    @State private var isSignedIn = false
    @State private var showingSignInSheet = false
    @State private var showingCreateAccountSheet = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Manage your account and preferences")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Account Options
            VStack(spacing: 12) {
                if !isSignedIn {
                    SettingsButton(
                        title: "Create Account",
                        subtitle: "Sign up for free cloud sync and backup",
                        icon: "person.badge.plus",
                        action: { showingCreateAccountSheet = true }
                    )
                    
                    SettingsButton(
                        title: "Sign In",
                        subtitle: "Access your data on any device",
                        icon: "person.circle",
                        action: { showingSignInSheet = true }
                    )
                } else {
                    SettingsButton(
                        title: "Account Settings",
                        subtitle: "Manage profile, privacy, and preferences",
                        icon: "person.crop.circle.badge.gearshape",
                        action: { /* Coming soon */ }
                    )
                    
                    SettingsButton(
                        title: "Subscription",
                        subtitle: "Manage your CoreTrack premium plan",
                        icon: "crown.fill",
                        action: { /* Coming soon */ }
                    )
                    
                    SettingsButton(
                        title: "Data & Privacy",
                        subtitle: "Manage your data and privacy settings",
                        icon: "hand.raised.fill",
                        action: { /* Coming soon */ }
                    )
                    
                    SettingsButton(
                        title: "Devices",
                        subtitle: "Manage connected devices and sync",
                        icon: "iphone.radiowaves.left.and.right",
                        action: { /* Coming soon */ }
                    )
                }
            }
        }
        .sheet(isPresented: $showingSignInSheet) {
            SignInView()
        }
        .sheet(isPresented: $showingCreateAccountSheet) {
            CreateAccountView()
        }
    }
}

struct SettingsButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button("Sign In") {
                    // TODO: Implement sign in
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button("Create Account") {
                    // TODO: Implement account creation
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AccountSettingsView()
} 