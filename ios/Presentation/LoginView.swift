import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showICloudWarning = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Login to MACRO")
                .font(.title)
                .foregroundColor(.white)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Login with Email") {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        alertMessage = error.localizedDescription
                        showAlert = true
                    } else {
                        alertMessage = "Login successful!"
                        showAlert = true
                    }
                }
            }
            Button("Login with Google") {
                // TODO: Implement Google login
            }
            Button("Login with iCloud") {
                showICloudWarning = true
            }
            .alert(isPresented: $showICloudWarning) {
                Alert(title: Text("iCloud Login"), message: Text("If you use iCloud login, your data cannot be merged to Android if you switch devices."), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .background(Color.black)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
