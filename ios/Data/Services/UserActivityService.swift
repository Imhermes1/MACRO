import Foundation

/// Service to track user activity and determine when to show welcome screen to returning users
class UserActivityService {
    static let shared = UserActivityService()
    
    private let lastActivityKey = "last_user_activity"
    private let welcomeShownKey = "welcome_shown_for_return"
    private let inactivityThresholdDays = 3
    
    private init() {}
    
    /// Record current activity timestamp
    func recordActivity() {
        let now = Date()
        UserDefaults.standard.set(now, forKey: lastActivityKey)
        
        // Reset the welcome shown flag when user is active
        UserDefaults.standard.set(false, forKey: welcomeShownKey)
        
        print("🕒 User activity recorded: \(now)")
    }
    
    /// Check if user should see welcome screen based on inactivity
    func shouldShowWelcomeForReturningUser() -> Bool {
        // Get last activity timestamp
        guard let lastActivity = UserDefaults.standard.object(forKey: lastActivityKey) as? Date else {
            // No previous activity recorded - this is a new user
            return false
        }
        
        // Check if welcome was already shown for this return period
        let welcomeAlreadyShown = UserDefaults.standard.bool(forKey: welcomeShownKey)
        if welcomeAlreadyShown {
            return false
        }
        
        // Calculate days since last activity
        let daysSinceLastActivity = Calendar.current.dateComponents([.day], from: lastActivity, to: Date()).day ?? 0
        
        let shouldShow = daysSinceLastActivity >= inactivityThresholdDays
        
        if shouldShow {
            print("🎉 Returning user after \(daysSinceLastActivity) days - showing welcome screen")
            markWelcomeShownForReturn()
        }
        
        return shouldShow
    }
    
    /// Mark that welcome screen has been shown for this return period
    private func markWelcomeShownForReturn() {
        UserDefaults.standard.set(true, forKey: welcomeShownKey)
    }
    
    /// Get days since last activity (for debugging/analytics)
    func daysSinceLastActivity() -> Int? {
        guard let lastActivity = UserDefaults.standard.object(forKey: lastActivityKey) as? Date else {
            return nil
        }
        
        return Calendar.current.dateComponents([.day], from: lastActivity, to: Date()).day
    }
    
    /// Clear activity data (used during sign out)
    func clearActivityData() {
        UserDefaults.standard.removeObject(forKey: lastActivityKey)
        UserDefaults.standard.removeObject(forKey: welcomeShownKey)
        print("🧹 User activity data cleared")
    }
    
    /// Test method: simulate 3+ days of inactivity for testing
    func simulateInactivity(days: Int = 3) {
        let simulatedDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        UserDefaults.standard.set(simulatedDate, forKey: lastActivityKey)
        UserDefaults.standard.set(false, forKey: welcomeShownKey)
        print("🧪 Simulated \(days) days of inactivity for testing")
    }
}
