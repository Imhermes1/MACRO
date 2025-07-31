import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserProfileRepository {
    private let key = "user_profile"
    private let defaults = UserDefaults.standard
    private let db = Firestore.firestore()

    func saveProfile(_ profile: UserProfile) {
        // Always save locally first for immediate access
        saveProfileLocally(profile)
        
        // Save to cloud if user is authenticated (not anonymous)
        if let user = Auth.auth().currentUser, !user.isAnonymous {
            saveProfileToCloud(profile, userId: user.uid)
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
    
    private func saveProfileToCloud(_ profile: UserProfile, userId: String) {
        var data: [String: Any] = [
            "firstName": profile.firstName,
            "age": profile.age,
            "height": profile.height,
            "weight": profile.weight,
            "lastUpdated": Timestamp(date: Date())
        ]
        if let lastName = profile.lastName {
            data["lastName"] = lastName
        }
        if let dob = profile.dob {
            data["dob"] = dob
        }
        
        db.collection("userProfiles").document(userId).setData(data) { error in
            if let error = error {
                // Error saving profile to cloud
            } else {
                // Profile successfully saved to cloud
            }
        }
    }

    func loadProfile(completion: @escaping (UserProfile?) -> Void = { _ in }) {
        // Try to load from cloud first if user is authenticated
        if let user = Auth.auth().currentUser, !user.isAnonymous {
            loadProfileFromCloud(userId: user.uid) { [weak self] cloudProfile in
                if let cloudProfile = cloudProfile {
                    // Save cloud data locally for offline access
                    self?.saveProfileLocally(cloudProfile)
                    completion(cloudProfile)
                } else {
                    // Fallback to local data
                    completion(self?.loadProfileLocally())
                }
            }
        } else {
            // For anonymous users, only use local storage
            completion(loadProfileLocally())
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
    
    private func loadProfileFromCloud(userId: String, completion: @escaping (UserProfile?) -> Void) {
        db.collection("userProfiles").document(userId).getDocument { document, error in
            if let error = error {
                // Error loading profile from cloud
                completion(nil)
                return
            }
            
            guard let document = document,
                  document.exists,
                  let data = document.data(),
                  let firstName = data["firstName"] as? String,
                  let age = data["age"] as? Int,
                  let height = data["height"] as? Float,
                  let weight = data["weight"] as? Float else {
                completion(nil)
                return
            }
            
            let lastName = data["lastName"] as? String
            let dob = data["dob"] as? String
            let profile = UserProfile(firstName: firstName, lastName: lastName, age: age, dob: dob, height: height, weight: weight)
            completion(profile)
        }
    }
    
    // Synchronous version for backward compatibility
    func loadProfile() -> UserProfile? {
        return loadProfileLocally()
    }
    
    /// Migrates local profile data to cloud when user upgrades from anonymous to authenticated
    func migrateLocalToCloud() {
        guard let user = Auth.auth().currentUser, !user.isAnonymous else { return }
        
        if let localProfile = loadProfileLocally() {
            saveProfileToCloud(localProfile, userId: user.uid)
        }
    }
    
    /// Deletes local profile data (useful when user signs out)
    func clearLocalProfile() {
        defaults.removeObject(forKey: key)
    }
    
    // MARK: - Cloud Provider Management
    
    private let cloudProviderKey = "selected_cloud_provider"
    
    /// Gets the currently selected cloud provider
    func getCurrentCloudProvider() -> CloudProvider {
        let rawValue = defaults.string(forKey: cloudProviderKey) ?? CloudProvider.localOnly.rawValue
        return CloudProvider(rawValue: rawValue) ?? .localOnly
    }
    
    /// Sets the cloud provider and migrates data if needed
    func setCloudProvider(_ provider: CloudProvider) {
        let currentProvider = getCurrentCloudProvider()
        defaults.set(provider.rawValue, forKey: cloudProviderKey)
        
        // If switching from one provider to another, migrate the data
        if currentProvider != provider {
            migrateDataBetweenProviders(from: currentProvider, to: provider)
        }
    }
    
    /// Gets available cloud providers based on device capabilities
    func getAvailableCloudProviders(completion: @escaping ([CloudProvider]) -> Void) {
        var providers: [CloudProvider] = [.localOnly]
        
        // Add Firebase if available (always available in this implementation)
        providers.append(.firebase)
        
        // Check CloudKit availability
        if CloudProvider.cloudKit.isAvailableOnCurrentPlatform {
            let cloudKitRepo = CloudKitUserProfileRepository()
            cloudKitRepo.checkCloudKitStatus { status in
                // CloudKit is considered available if we can determine its status
                // Even if user is not signed in, we show it as an option
                if !status.contains("Cannot determine") {
                    providers.append(.cloudKit)
                }
                
                DispatchQueue.main.async {
                    completion(providers)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(providers)
            }
        }
    }
    
    /// Migrates profile data between cloud providers
    private func migrateDataBetweenProviders(from: CloudProvider, to: CloudProvider) {
        guard let currentProfile = loadProfile() else { return }
        
        switch to {
        case .localOnly:
            // Data is already saved locally, no migration needed
            break
        case .firebase:
            // Save to Firebase (existing saveProfile method handles this)
            saveProfile(currentProfile)
        case .cloudKit:
            // Save to CloudKit
            let cloudKitRepo = CloudKitUserProfileRepository()
            cloudKitRepo.saveProfile(currentProfile)
        }
        
        // Profile data migrated from \(from.displayName) to \(to.displayName)
    }
}
