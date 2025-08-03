import Foundation
import CloudKit

/// CloudKit-native profile repository for iOS users who prefer Apple's ecosystem
class CloudKitUserProfileRepository {
    private let key = "user_profile"
    private let defaults = UserDefaults.standard
    private let cloudKitService = CloudKitProfileService()
    
    func saveProfile(_ profile: UserProfile) {
        // Always save locally first for immediate access
        saveProfileLocally(profile)
        
        // Save to CloudKit if available
        cloudKitService.isCloudKitAvailable { [weak self] isAvailable in
            if isAvailable {
                self?.cloudKitService.saveProfile(profile) { result in
                    switch result {
                    case .success:
                        break // Profile successfully saved to CloudKit
                    case .failure(_):
                        break // Failed to save to CloudKit
                    }
                }
            } else {
                // CloudKit not available - profile saved locally only
            }
        }
    }
    
    private func saveProfileLocally(_ profile: UserProfile) {
        var dict: [String: Any] = [
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
    
    func loadProfile(completion: @escaping (UserProfile?) -> Void = { _ in }) {
        cloudKitService.isCloudKitAvailable { [weak self] isAvailable in
            if isAvailable {
                self?.cloudKitService.loadProfile { result in
                    switch result {
                    case .success(let cloudProfile):
                        if let cloudProfile = cloudProfile {
                            // Save cloud data locally for offline access
                            self?.saveProfileLocally(cloudProfile)
                            completion(cloudProfile)
                        } else {
                            // No cloud data, fallback to local
                            completion(self?.loadProfileLocally())
                        }
                    case .failure(_):
                        // Failed to load from CloudKit, fallback to local data
                        completion(self?.loadProfileLocally())
                    }
                }
            } else {
                // CloudKit not available, use local storage
                completion(self?.loadProfileLocally())
            }
        }
    }
    
    private func loadProfileLocally() -> UserProfile? {
        guard let dict = defaults.dictionary(forKey: key) else { return nil }
        guard let firstName = dict["firstName"] as? String,
              let age = dict["age"] as? Int,
              let height = dict["height"] as? Float,
              let weight = dict["weight"] as? Float else { return nil }
        let lastName = dict["lastName"] as? String
        let dob = dict["dob"] as? String
        return UserProfile(firstName: firstName, lastName: lastName, age: age, dob: dob, height: height, weight: weight)
    }
    
    // MARK: - CloudKit Status
    
    func checkCloudKitStatus(completion: @escaping (String) -> Void) {
        cloudKitService.checkAccountStatus { status in
            let statusMessage: String
            switch status {
            case .available:
                statusMessage = "✅ iCloud is available and syncing"
            case .noAccount:
                statusMessage = "⚠️ No iCloud account. Sign in to Settings > [Your Name] > iCloud"
            case .restricted:
                statusMessage = "🚫 iCloud is restricted by parental controls or device management"
            case .couldNotDetermine:
                statusMessage = "❓ Cannot determine iCloud status"
            case .temporarilyUnavailable:
                statusMessage = "⏳ iCloud is temporarily unavailable"
            @unknown default:
                statusMessage = "❓ Unknown iCloud status"
            }
            completion(statusMessage)
        }
    }
    
    /// Deletes local profile data (useful when user signs out)
    func clearLocalProfile() {
        defaults.removeObject(forKey: key)
    }
    
    // Synchronous version for backward compatibility
    func loadProfile() -> UserProfile? {
        return loadProfileLocally()
    }
}
