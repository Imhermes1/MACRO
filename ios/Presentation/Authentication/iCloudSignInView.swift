import SwiftUI
import CloudKit

struct iCloudSignInView: View {
    @StateObject private var authService = CloudKitAuthenticationService()
    @State private var showingSignInPrompt = false
    
    let onSignInComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // iCloud Logo
            VStack(spacing: 16) {
                Image(systemName: authService.accountStatus.systemImage)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .opacity(0.9)
                
                Text("iCloud Sync")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Status Message
            Text(authService.statusMessage)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Action Buttons
            VStack(spacing: 16) {
                if authService.accountStatus == .available {
                    Button("Continue with iCloud") {
                        onSignInComplete()
                    }
                    .buttonStyle(iCloudButtonStyle())
                } else if authService.accountStatus == .noAccount {
                    VStack(spacing: 12) {
                        Button("Set Up iCloud") {
                            showingSignInPrompt = true
                        }
                        .buttonStyle(iCloudButtonStyle())
                        
                        Button("Continue Without iCloud") {
                            onSignInComplete()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                } else {
                    Button("Retry") {
                        authService.checkAccountStatus()
                    }
                    .buttonStyle(iCloudButtonStyle())
                    
                    Button("Continue Without iCloud") {
                        onSignInComplete()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Footer Info
            if authService.accountStatus != .available {
                VStack(spacing: 8) {
                    Text("iCloud keeps your data in sync across all your devices")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    Text("You can always enable it later in Settings")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.3),
                    Color.cyan.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .alert("Set Up iCloud", isPresented: $showingSignInPrompt) {
            Button("Open Settings") {
                authService.promptiCloudSignIn()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("To use iCloud sync, please sign in to your Apple ID in Settings > [Your Name] > iCloud")
        }
        .onAppear {
            authService.checkAccountStatus()
        }
        .onChange(of: authService.accountStatus) { status in
            if status == .available {
                // Auto-continue if user signs in successfully
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onSignInComplete()
                }
            }
        }
    }
}

// MARK: - Custom Button Styles

struct iCloudButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.cyan
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.1))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

struct iCloudSignInView_Previews: PreviewProvider {
    static var previews: some View {
        iCloudSignInView {
            print("Sign in completed")
        }
    }
}
