import SwiftUI
import Combine
import Supabase
import AuthenticationServices
import CryptoKit

/// Handles Apple Sign In flow and integrates with Supabase.
class AppleSignInManager: NSObject, ObservableObject {
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    
    // Keep strong references to delegates to prevent deallocation
    fileprivate var continuationDelegate: AppleSignInContinuationDelegate?
    fileprivate var presentationProvider: ApplePresentationProvider?
    
    func startSignInWithAppleFlow() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    /// Modern async/await Apple Sign-In that returns idToken and nonce (for Supabase)
    func signInWithApple(on window: UIWindow) async throws -> (String, String?, PersonNameComponents?) {
        return try await withCheckedThrowingContinuation { continuation in
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let nonce = randomNonceString()
            request.nonce = sha256(nonce)
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            // Store strong references to prevent deallocation
            self.continuationDelegate = AppleSignInContinuationDelegate(continuation: continuation, nonce: nonce, manager: self)
            self.presentationProvider = ApplePresentationProvider(window: window)
            
            controller.delegate = self.continuationDelegate
            controller.presentationContextProvider = self.presentationProvider
            controller.performRequests()
        }
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
                let session = try await supabase.auth.signInWithIdToken(
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
    
    func createUserProfileIfNeeded(user: User, firstName: String = "", lastName: String = "") {
        Task {
            do {
                // Create a proper encodable dictionary using individual values
                var insertQuery = supabase.from("profiles")
                
                if !firstName.isEmpty && !lastName.isEmpty {
                    // Both names available
                    let fullName = "\(firstName) \(lastName)"
                    try await insertQuery.insert([
                        "user_id": user.id.uuidString,
                        "email": user.email ?? "",
                        "first_name": firstName,
                        "last_name": lastName,
                        "full_name": fullName
                    ], returning: .minimal).execute()
                } else if !firstName.isEmpty {
                    // Only first name
                    try await insertQuery.insert([
                        "user_id": user.id.uuidString,
                        "email": user.email ?? "",
                        "first_name": firstName,
                        "full_name": firstName
                    ], returning: .minimal).execute()
                } else if !lastName.isEmpty {
                    // Only last name
                    try await insertQuery.insert([
                        "user_id": user.id.uuidString,
                        "email": user.email ?? "",
                        "last_name": lastName,
                        "full_name": lastName
                    ], returning: .minimal).execute()
                } else {
                    // No names available
                    try await insertQuery.insert([
                        "user_id": user.id.uuidString,
                        "email": user.email ?? ""
                    ], returning: .minimal).execute()
                }
                
                let fullName = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
                print("Created Apple Supabase profile - First: '\(firstName)', Last: '\(lastName)', Full: '\(fullName)'")
            } catch {
                print("Profile creation error: \(error)")
                // Don't fail the sign-in process if profile creation fails
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                try await supabase.auth.signOut()
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

// MARK: - Async/Await Delegate for Apple Sign In
fileprivate class AppleSignInContinuationDelegate: NSObject, ASAuthorizationControllerDelegate {
    let continuation: CheckedContinuation<(String, String?, PersonNameComponents?), Error>
    let nonce: String
    weak var manager: AppleSignInManager?
    
    init(continuation: CheckedContinuation<(String, String?, PersonNameComponents?), Error>, nonce: String, manager: AppleSignInManager? = nil) {
        self.continuation = continuation
        self.nonce = nonce
        self.manager = manager
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { cleanup() }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken,
           let idTokenStr = String(data: identityToken, encoding: .utf8) {
            continuation.resume(returning: (idTokenStr, nonce, appleIDCredential.fullName))
        } else {
            continuation.resume(throwing: NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Apple identity token"]))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        defer { cleanup() }
        continuation.resume(throwing: error)
    }
    
    private func cleanup() {
        manager?.continuationDelegate = nil
        manager?.presentationProvider = nil
    }
}

fileprivate class ApplePresentationProvider: NSObject, ASAuthorizationControllerPresentationContextProviding {
    let window: UIWindow
    init(window: UIWindow) { self.window = window }
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return window
    }
}

// MARK: - Nonce Generation Helpers
private func randomNonceString(length: Int = 32) -> String {
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess { fatalError("Unable to generate nonce. SecRandomCopyBytes failed.") }
            return random
        }
        randoms.forEach { random in
            if remainingLength == 0 { return }
            if random < charset.count {
                result.append(charset[Int(random) % charset.count])
                remainingLength -= 1
            }
        }
    }
    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashed = SHA256.hash(data: inputData)
    return hashed.compactMap { String(format: "%02x", $0) }.joined()
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
