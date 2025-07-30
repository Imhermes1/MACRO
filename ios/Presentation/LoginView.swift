
import SwiftUI
// UniversalBackground is a local SwiftUI View
import FirebaseAuth

struct LoginView: View {
    @ObservedObject var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var showICloudWarning = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                UniversalBackground()
                VStack(spacing: 20) {
                    Text("Welcome to MACRO")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.white)
                            TextField("Email", text: $email)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(25)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                            SecureField("Password", text: $password)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(25)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                                if let error = error {
                                    alertMessage = error.localizedDescription
                                    showAlert = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("Login with Email")
                            }
                            .modifier(PillButtonStyle())
                        }
                        
                        Button(action: {
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
                            // TODO: Implement Google login
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Login with Google")
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
                    .padding(.top, 20)
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.all) // Ensure full screen coverage
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
