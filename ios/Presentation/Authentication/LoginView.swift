
import SwiftUI
import CloudKit

struct LoginView: View {
    @ObservedObject var session: SessionStore
    @State private var showICloudWarning = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                UniversalBackground()
                VStack(spacing: 32) {
                    // Animated Glow Logo
                    AnimatedGlowLogo()
                    // Centered Multiline Welcome Text
                    VStack(spacing: 0) {
                        Text("Welcome to Macro")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("by")
                            .font(.title2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Lumora Labs")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 24)
                    // Login Buttons Only
                    VStack(spacing: 20) {
                        Button(action: {
                            // Email login - show alert for now
                            alertMessage = "Email login not implemented yet"
                            showAlert = true
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Login with Email")
                            }
                            .modifier(PillButtonStyle())
                        }
                        Button(action: {
                            // Google login - show alert for now
                            alertMessage = "Google login not implemented yet"
                            showAlert = true
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Login with Google")
                            }
                            .modifier(PillButtonStyle())
                        }
                        Button(action: {
                            // Demo login without Firebase
                            session.isLoggedIn = true
                            session.currentUser = "demo_user"
                            session.checkUserProfile()
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Login Anonymously (Demo)")
                            }
                            .modifier(PillButtonStyle())
                        }
                        Button(action: {
                            // iCloud/CloudKit login
                            signiCloudLogin()
                        }) {
                            HStack {
                                Image(systemName: "icloud.fill")
                                Text("Login with iCloud")
                            }
                            .modifier(PillButtonStyle())
                        }
                        .alert(isPresented: $showICloudWarning) {
                            Alert(title: Text("iCloud Login"), message: Text("If you use iCloud login, your data cannot be merged to Android if you switch devices."), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.all)
        }
    }
    
    // MARK: - iCloud Login Function
    private func signiCloudLogin() {
        let container = CKContainer(identifier: "iCloud.com.lumoralabs.macro")
        
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    // iCloud account is available, proceed with login
                    session.isLoggedIn = true
                    session.currentUser = "icloud_user"
                    session.checkUserProfile()
                    
                case .noAccount:
                    alertMessage = "No iCloud account found. Please sign in to iCloud in Settings."
                    showAlert = true
                    
                case .restricted:
                    alertMessage = "iCloud account is restricted."
                    showAlert = true
                    
                case .temporarilyUnavailable:
                    alertMessage = "iCloud is temporarily unavailable. Please try again."
                    showAlert = true
                    
                case .couldNotDetermine:
                    alertMessage = "Could not determine iCloud account status."
                    showAlert = true
                    
                @unknown default:
                    alertMessage = "Unknown iCloud account status."
                    showAlert = true
                }
            }
        }
    }
}

struct PillButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.2))
            .clipShape(Capsule())
    }
}

// Animated glowing logo view - Enhanced Lumos effect
import SwiftUI
struct AnimatedGlowLogo: View {
    @State private var glow = false
    @State private var pulse = false
    @State private var sparkle = false
    
    var body: some View {
        ZStack {
            // Outer magical aura - static size for stable experience
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.yellow.opacity(glow ? 0.4 : 0.1),
                            Color.white.opacity(glow ? 0.3 : 0.05),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 10,
                        endRadius: 150
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 20)
            
            // Main logo with enhanced shadows
            Image("LumoraLabsLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 240)
                .padding(.top, -16)
                // Multiple layered shadows for depth
                .shadow(color: glow ? Color.yellow.opacity(1.0) : Color.white.opacity(0.8), radius: glow ? 100 : 50, x: 0, y: 0)
                .shadow(color: glow ? Color.white.opacity(0.9) : Color.yellow.opacity(0.7), radius: glow ? 60 : 30, x: 0, y: 0)
                .shadow(color: glow ? Color.yellow.opacity(0.8) : Color.white.opacity(0.6), radius: glow ? 30 : 15, x: 0, y: 0)
                .shadow(color: glow ? Color.white.opacity(0.7) : Color.yellow.opacity(0.4), radius: glow ? 15 : 8, x: 0, y: 0)
                // Subtle sparkle effect
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.yellow.opacity(sparkle ? 0.8 : 0.2),
                                    Color.white.opacity(sparkle ? 0.6 : 0.1),
                                    Color.yellow.opacity(sparkle ? 0.4 : 0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: sparkle ? 3 : 1
                        )
                        .frame(width: 250, height: 250)
                        .blur(radius: 2)
                )
        }
        .onAppear {
            // Only gentle glow animation - no pulse or sparkle for stable UI
            withAnimation(Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                glow = true
            }
            // Remove pulse and sparkle animations for stable experience
            // pulse = true
            // sparkle = true
        }
    }
}
