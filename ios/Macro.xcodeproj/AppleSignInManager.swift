import SwiftUI
import Supabase
import AuthenticationServices
import Combine
import Foundation

/// Handles Apple Sign In flow and integrates with Supabase.
class AppleSignInManager: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    
    func startSignInWithAppleFlow() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func handleSuccessfulSignIn(credential: ASAuthorizationAppleIDCredential) {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            errorMessage = "Could not retrieve identity token"
            return
        }
        Task {
            do {
                // Supabase Apple OAuth Sign In
                let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(
                    credentials: .init(
                        provider: .apple,
                        idToken: tokenString
                    )
                )
                await MainActor.run {
                    self.isSignedIn = true
                    self.createUserProfileIfNeeded(user: session.user)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSignedIn = false
                }
            }
        }
    }
    
    private func createUserProfileIfNeeded(user: User) {
        Task {
            do {
                // Optional: Create a profile in your profiles table
                let profileData = [
                    "user_id": user.id,
                    "email": user.email ?? "",
                    "full_name": user.userMetadata?["full_name"] as? String ?? ""
                ]
                try await SupabaseManager.shared.client
                    .from("profiles")
                    .insert(profileData)
                    .execute()
            } catch {
                print("Profile creation error: \(error)")
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signOut()
                await MainActor.run {
                    self.isSignedIn = false
                }
            } catch {
                print("Sign out error: \(error)")
            }
        }
    }
}

// MARK: - ASAuthorization Delegates
extension AppleSignInManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            handleSuccessfulSignIn(credential: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Replace this with your app's key window if needed
        ASPresentationAnchor()
    }
}


/// SwiftUI View for Apple Sign In
struct AppleSignInView: View {
    @StateObject private var appleSignInManager = AppleSignInManager()
    
    var body: some View {
        VStack {
            if appleSignInManager.isSignedIn {
                Text("Signed In Successfully")
                Button("Sign Out") {
                    appleSignInManager.signOut()
                }
            } else {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success:
                            appleSignInManager.startSignInWithAppleFlow()
                        case .failure(let error):
                            print("Apple Sign In Error: \(error)")
                        }
                    }
                )
                .frame(width: 280, height: 50)
                .cornerRadius(8)
            }
            
            if let errorMessage = appleSignInManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
    }
}
