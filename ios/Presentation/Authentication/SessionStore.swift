import Foundation
import FirebaseAuth
import Combine

class SessionStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isProfileComplete = false
    @Published var isWelcomeScreenSeen = false
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
                self.isWelcomeScreenSeen = false
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
        
        // Use the async version to load from cloud if available
        profileRepo.loadProfile { [weak self] profile in
            DispatchQueue.main.async {
                if let profile = profile {
                    self?.isProfileComplete = true
                    // Check both UserDefaults flags for completion states
                    let defaults = UserDefaults.standard
                    self?.isWelcomeScreenSeen = defaults.bool(forKey: "welcome_screen_seen")
                    self?.isBMIComplete = defaults.bool(forKey: "bmi_calculator_completed")
                } else {
                    self?.isProfileComplete = false
                    self?.isWelcomeScreenSeen = false
                    self?.isBMIComplete = false
                }
            }
        }
    }
    
    func markWelcomeScreenSeen() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "welcome_screen_seen")
        isWelcomeScreenSeen = true
    }
    
    func markBMICalculatorCompleted() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "bmi_calculator_completed")
        isBMIComplete = true
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Reset completion flags when signing out
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "bmi_calculator_completed")
            defaults.removeObject(forKey: "welcome_screen_seen")
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
