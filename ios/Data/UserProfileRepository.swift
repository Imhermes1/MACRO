import Foundation
import Combine
// The UserProfile struct is defined in UserProfile.swift and available throughout the target—no import needed.

/**
 * UserProfileRepository - Simplified profile management for iOS
 * Handles local storage of user profiles with future cloud sync capabilities
 * 
 * This follows Apple's recommended local-first strategy for iOS apps.
 * Data is immediately saved locally and can be extended with cloud sync.
 */
@MainActor
class UserProfileRepository: ObservableObject {
    private let key = "user_profile"
    private let defaults = UserDefaults.standard
    
    @Published var currentProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        self.currentProfile = loadProfileLocally()
    }

    func saveProfile(_ profile: UserProfile) {
        isLoading = true
        errorMessage = nil
        
        // Save locally first for immediate access
        saveProfileLocally(profile)
        
        // Update published property
        currentProfile = profile
        
        // TODO: Add cloud sync when authentication is implemented
        // For now, we'll stick to local storage to avoid import issues
        
        isLoading = false
    }
    
    private func saveProfileLocally(_ profile: UserProfile) {
        var dict: [String: Any] = [
            "id": profile.id,
            "firstName": profile.firstName,
            "age": profile.age,
            "height": profile.height,
            "weight": profile.weight
        ]
        if let lastName = profile.lastName {
            dict["lastName"] = lastName
        }
        if let dob = profile.dob {
            dict["dob"] = dob
        }
        defaults.set(dict, forKey: key)
    }
    
    func loadProfile() -> UserProfile? {
        let profile = loadProfileLocally()
        currentProfile = profile
        return profile
    }
    
    private func loadProfileLocally() -> UserProfile? {
        guard let dict = defaults.dictionary(forKey: key) else { return nil }
        
        guard let id = dict["id"] as? String,
              let firstName = dict["firstName"] as? String,
              let age = dict["age"] as? Int,
              let height = dict["height"] as? Float,
              let weight = dict["weight"] as? Float else {
            return nil
        }
        
        let lastName = dict["lastName"] as? String
        let dob = dict["dob"] as? String
        
        return UserProfile(
            firstName: firstName,
            lastName: lastName,
            age: age,
            dob: dob,
            height: height,
            weight: weight,
            id: id
        )
    }
    
    func clearProfile() {
        defaults.removeObject(forKey: key)
        currentProfile = nil
    }
    
    var hasProfile: Bool {
        return currentProfile != nil || defaults.dictionary(forKey: key) != nil
    }
    
    // MARK: - Profile Updates
    
    func updateProfile(firstName: String? = nil, lastName: String? = nil, age: Int? = nil, height: Float? = nil, weight: Float? = nil) {
        guard let current = currentProfile else { return }
        
        let updated = UserProfile(
            firstName: firstName ?? current.firstName,
            lastName: lastName ?? current.lastName,
            age: age ?? current.age,
            dob: current.dob,
            height: height ?? current.height,
            weight: weight ?? current.weight,
            id: current.id
        )
        
        saveProfile(updated)
    }
    
    // MARK: - Utility Functions
    
    func getProfileSummary() -> String {
        guard let profile = currentProfile else {
            return "No profile available"
        }
        
        let name = [profile.firstName, profile.lastName].compactMap { $0 }.joined(separator: " ")
        return "\(name), Age: \(profile.age), Height: \(profile.height)cm, Weight: \(profile.weight)kg"
    }
    
    // MARK: - Cloud Provider Stubs for Compatibility
    func getAvailableCloudProviders() -> [String] {
        // TODO: Replace with real providers if needed
        return []
    }

    func setCloudProvider(_ provider: String) {
        // TODO: Implement cloud provider selection logic
    }

    func getCurrentCloudProvider() -> String? {
        // TODO: Return selected provider if implemented
        return nil
    }
}

