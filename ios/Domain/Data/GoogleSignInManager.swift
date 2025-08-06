import Foundation
import GoogleSignIn
import UIKit
import Supabase

class GoogleSignInManager {
    
    func signInWithGoogle() async throws -> (idToken: String, firstName: String, lastName: String, email: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw NSError(domain: "GoogleSignInManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find root view controller."])
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw NSError(domain: "GoogleSignInManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Google ID token not found."])
        }
        
        // Extract user profile information
        let user = gidSignInResult.user
        let firstName = user.profile?.givenName ?? ""
        let lastName = user.profile?.familyName ?? ""
        let email = user.profile?.email ?? ""
        
        print("Google user info - First: '\(firstName)', Last: '\(lastName)', Email: '\(email)'")
        
        return (idToken: idToken, firstName: firstName, lastName: lastName, email: email)
    }
    
    func createGoogleUserProfile(userId: String, firstName: String, lastName: String, email: String) async {
        Task {
            do {
                // Create a proper encodable dictionary using individual values
                var insertQuery = SupabaseManager.shared.client.from("profiles")
                
                if !firstName.isEmpty && !lastName.isEmpty {
                    // Both names available
                    let fullName = "\(firstName) \(lastName)"
                    try await insertQuery.insert([
                        "user_id": userId,
                        "email": email,
                        "first_name": firstName,
                        "last_name": lastName,
                        "full_name": fullName
                    ], returning: .minimal).execute()
                } else if !firstName.isEmpty {
                    // Only first name
                    try await insertQuery.insert([
                        "user_id": userId,
                        "email": email,
                        "first_name": firstName,
                        "full_name": firstName
                    ], returning: .minimal).execute()
                } else if !lastName.isEmpty {
                    // Only last name
                    try await insertQuery.insert([
                        "user_id": userId,
                        "email": email,
                        "last_name": lastName,
                        "full_name": lastName
                    ], returning: .minimal).execute()
                } else {
                    // No names available
                    try await insertQuery.insert([
                        "user_id": userId,
                        "email": email
                    ], returning: .minimal).execute()
                }
                
                let fullName = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
                print("Created Google Supabase profile - First: '\(firstName)', Last: '\(lastName)', Full: '\(fullName)'")
            } catch {
                print("Google profile creation error: \(error)")
                // Don't fail the sign-in process if profile creation fails
            }
        }
    }
}
