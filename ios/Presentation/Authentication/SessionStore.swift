import Foundation
import Combine
import CloudKit

class SessionStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isProfileComplete = false
    @Published var isWelcomeScreenSeen = false
    @Published var isBMIComplete = false
    @Published var currentUser: String? // Changed to String for demo
    @Published var iCloudAvailable = false
    
    private let cloudKitContainer = CKContainer(identifier: "iCloud.com.lumoralabs.macro")
    
    init() {
        checkiCloudStatus()
    }
    
    func checkiCloudStatus() {
        cloudKitContainer.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.iCloudAvailable = (status == .available)
            }
        }
    }
    
    func listen() {
        // Demo mode - automatically log in
        self.isLoggedIn = true
        self.currentUser = "demo_user"
        self.checkUserProfile()
    }
    
    func getUserDisplayName() -> String? {
        return "Demo User"
    }
    
    func getUserEmail() -> String? {
        return "demo@example.com"
    }
    
    func extractUserDetails() -> (firstName: String?, lastName: String?, email: String?) {
        return ("Demo", "User", "demo@example.com")
    }
    
    func checkUserProfile() {
        // For demo mode, check UserDefaults for profile completion
        let defaults = UserDefaults.standard
        self.isProfileComplete = defaults.bool(forKey: "profile_complete")
        self.isWelcomeScreenSeen = defaults.bool(forKey: "welcome_screen_seen")
        self.isBMIComplete = defaults.bool(forKey: "bmi_calculator_completed")
        
        // If using iCloud, also check CloudKit
        if currentUser == "icloud_user" && iCloudAvailable {
            syncWithCloudKit()
        }
    }
    
    private func syncWithCloudKit() {
        // For now, we'll just mark CloudKit sync as completed
        // This can be expanded later with proper CloudKit integration
        UserDefaults.standard.set(true, forKey: "cloudkit_synced")
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
        // Reset completion flags when signing out
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "bmi_calculator_completed")
        defaults.removeObject(forKey: "welcome_screen_seen")
        defaults.removeObject(forKey: "profile_complete")
        isLoggedIn = false
        currentUser = nil
        isProfileComplete = false
        isWelcomeScreenSeen = false
        isBMIComplete = false
    }
}
