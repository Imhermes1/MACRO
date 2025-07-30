
import SwiftUI
// UniversalBackground is a local SwiftUI View
import FirebaseAuth

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
                            // Anonymous login - actually sign in
                            Auth.auth().signInAnonymously { result, error in
                                if let error = error {
                                    alertMessage = error.localizedDescription
                                    showAlert = true
                                } else {
                                    // For demo purposes, simulate user profile data
                                    if let user = result?.user {
                                        let changeRequest = user.createProfileChangeRequest()
                                        changeRequest.displayName = "Demo User"
                                        changeRequest.commitChanges { _ in }
                                    }
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Login Anonymously (Demo)")
                            }
                            .modifier(PillButtonStyle())
                        }
                        Button(action: {
                            showICloudWarning = true
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

// Animated glowing logo view
import SwiftUI
struct AnimatedGlowLogo: View {
    @State private var glow = false
    
    var body: some View {
        Image("LumoraLabsLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 240, height: 240)
            .padding(.top, -16)
            .shadow(color: glow ? Color.yellow.opacity(1.0) : Color.white.opacity(0.8), radius: glow ? 80 : 40, x: 0, y: 0)
            .shadow(color: glow ? Color.white.opacity(0.9) : Color.yellow.opacity(0.6), radius: glow ? 40 : 60, x: 0, y: 0)
            .shadow(color: glow ? Color.yellow.opacity(0.7) : Color.white.opacity(0.5), radius: glow ? 20 : 30, x: 0, y: 0)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glow = true
                }
            }
    }
}


struct MainAppView: View {
    var body: some View {
        ZStack {
            UniversalBackground()
            VStack(spacing: 20) {
                Text("Welcome to MACRO!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your nutrition tracking app")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(32)
        }
        .ignoresSafeArea(.all) // Ensure full screen coverage
    }
}
