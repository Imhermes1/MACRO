import Foundation
import Supabase
import Combine
import UIKit

@MainActor
class AuthManager: ObservableObject {
    @Published var session: Session?
    @Published var errorMessage: String?
    @Published var userFirstName: String = ""
    @Published var userLastName: String = ""
    @Published var userEmail: String = ""

    private var authStateTask: Task<Void, Never>?
    private let appleSignInManager = AppleSignInManager()
    private let googleSignInManager = GoogleSignInManager()

    init() {
        authStateTask = Task {
            for await (event, session) in SupabaseManager.shared.client.auth.authStateChanges {
                // This runs on a background thread. We need to switch to the main thread to update UI.
                await MainActor.run {
                    self.session = session
                    print("Auth event: \(event), session: \(session?.user.email ?? "nil")")
                }
            }
        }
    }

    deinit {
        authStateTask?.cancel()
    }

    func signIn(with email: String, password: String) async {
        do {
            let session = try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
            self.session = session
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signUp(with email: String, password: String) async {
        do {
            let response = try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
            self.session = response.session
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signInAnonymously() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.signInAnonymously()
            self.session = session
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
            self.session = nil
            // Clear stored user data
            self.userFirstName = ""
            self.userLastName = ""
            self.userEmail = ""
            
            // NUCLEAR OPTION: Clear ALL UserDefaults to ensure fresh start
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
            }
            
            // Also manually clear any specific keys we know about
            let keysToRemove = [
                "user_profile",
                "has_seen_app_demo",
                "has_completed_onboarding",
                "user_goals",
                "calorie_goal",
                "macro_goals",
                "fitness_level",
                "activity_level"
            ]
            
            for key in keysToRemove {
                UserDefaults.standard.removeObject(forKey: key)
            }
            
            // Force synchronization
            UserDefaults.standard.synchronize()
            
            print("🧹 COMPLETE RESET: All user data cleared")
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signInWithApple() async {
        #if os(iOS)
        guard let window = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .filter({ $0.isKeyWindow }).first else {
            self.errorMessage = "Could not get active window."
            print("Apple Sign-In Error: Could not get active window")
            return
        }
        
        do {
            print("Starting Apple Sign-In...")
            let (idToken, nonce, nameComponents) = try await appleSignInManager.signInWithApple(on: window)
            print("Apple Sign-In successful, got ID token")
            print("ID Token length: \(idToken.count)")
            print("Nonce: \(nonce ?? "nil")")
            
            // Extract separate first and last names from Apple credential
            var firstName = ""
            var lastName = ""
            var displayName = ""
            
            if let nameComponents = nameComponents {
                firstName = nameComponents.givenName ?? ""
                lastName = nameComponents.familyName ?? ""
                displayName = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
                print("First name: '\(firstName)'")
                print("Last name: '\(lastName)'")
                print("Display name: '\(displayName)'")
            }
            
            print("Attempting Supabase authentication...")
            let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(
                credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
            )
            
            print("Supabase authentication successful!")
            print("User ID: \(session.user.id)")
            print("User email: \(session.user.email ?? "no email")")
            
            // Create user profile with Apple name information
            await appleSignInManager.createUserProfileIfNeeded(
                user: session.user,
                firstName: firstName,
                lastName: lastName
            )
            
            await MainActor.run {
                self.session = session
                self.errorMessage = nil
                // Store user data for profile setup
                self.userFirstName = firstName
                self.userLastName = lastName
                self.userEmail = session.user.email ?? ""
                print("Session set on main actor, should trigger UI update")
                print("Stored Apple user data - First: '\(firstName)', Last: '\(lastName)', Email: '\(self.userEmail)'")
            }
        } catch {
            print("Apple Sign-In Error: \(error)")
            print("Error details: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
        #endif
    }
    
    func signInWithGoogle() async {
        #if os(iOS)
        do {
            print("Starting Google Sign-In...")
            let googleResult = try await googleSignInManager.signInWithGoogle()
            print("Google Sign-In successful, got ID token")
            print("ID Token length: \(googleResult.idToken.count)")
            print("First name: '\(googleResult.firstName)'")
            print("Last name: '\(googleResult.lastName)'")
            print("Email: '\(googleResult.email)'")
            
            print("Attempting Supabase authentication...")
            let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(
                credentials: .init(provider: .google, idToken: googleResult.idToken)
            )
            
            print("Supabase authentication successful!")
            print("User ID: \(session.user.id)")
            print("User email: \(session.user.email ?? "no email")")
            
            // Create user profile with Google name information
            await googleSignInManager.createGoogleUserProfile(
                userId: session.user.id.uuidString,
                firstName: googleResult.firstName,
                lastName: googleResult.lastName,
                email: googleResult.email
            )
            
            await MainActor.run {
                self.session = session
                self.errorMessage = nil
                // Store user data for profile setup
                self.userFirstName = googleResult.firstName
                self.userLastName = googleResult.lastName
                self.userEmail = googleResult.email
                print("Session set on main actor, should trigger UI update")
                print("Stored Google user data - First: '\(googleResult.firstName)', Last: '\(googleResult.lastName)', Email: '\(googleResult.email)'")
            }
            
        } catch {
            print("Google Sign-In Error: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
        #endif
    }
}

