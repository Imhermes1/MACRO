import Foundation
import FirebaseAuth
import Combine

class SessionStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isProfileComplete = false
    @Published var isBMIComplete = false
    @Published var currentUser: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    func listen() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            if let user = user {
                self.isLoggedIn = true
                self.currentUser = user
                self.checkUserProfile()
            } else {
                self.isLoggedIn = false
                self.isProfileComplete = false
                self.isBMIComplete = false
                self.currentUser = nil
            }
        }
    }
    
    func getUserDisplayName() -> String? {
        return currentUser?.displayName
    }
    
    func getUserEmail() -> String? {
        return currentUser?.email
    }
    
    func extractUserDetails() -> (firstName: String?, lastName: String?, email: String?) {
        guard let user = currentUser else { return (nil, nil, nil) }
        
        let displayName = user.displayName
        let email = user.email
        
        var firstName: String?
        var lastName: String?
        
        if let displayName = displayName, !displayName.isEmpty {
            let nameParts = displayName.components(separatedBy: " ")
            firstName = nameParts.first
            if nameParts.count > 1 {
                lastName = nameParts.dropFirst().joined(separator: " ")
            }
        }
        
        return (firstName, lastName, email)
    }
    
    func checkUserProfile() {
        let profileRepo = UserProfileRepository()
        if let profile = profileRepo.loadProfile() {
            self.isProfileComplete = true
            // Check if BMI data exists (height and weight are set)
            if profile.height > 0 && profile.weight > 0 {
                self.isBMIComplete = true
            } else {
                self.isBMIComplete = false
            }
        } else {
            self.isProfileComplete = false
            self.isBMIComplete = false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out")
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
