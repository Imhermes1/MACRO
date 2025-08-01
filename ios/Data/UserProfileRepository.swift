import Foundation

class UserProfileRepository {
    private let key = "user_profile"
    private let defaults = UserDefaults.standard
    private let supabaseService = SupabaseService()

    func saveProfile(_ profile: UserProfile) {
        // Always save locally first for immediate access
        saveProfileLocally(profile)
        
        // Save to cloud if user is authenticated
        Task {
            let user = await supabaseService.getCurrentUser()
            if let user = user {
                try? await saveProfileToCloud(profile, userId: user.id)
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
    
    private func saveProfileToCloud(_ profile: UserProfile, userId: String) async throws {
        var data: [String: Any] = [
            "id": userId,
            "firstName": profile.firstName,
            "age": profile.age,
            "height": profile.height,
            "weight": profile.weight,
            "lastUpdated": Date().timeIntervalSince1970
        ]
        if let lastName = profile.lastName {
            data["lastName"] = lastName
        }
        if let dob = profile.dob {
            data["dob"] = dob
        }
        
        // TODO: Replace with actual Supabase client implementation
        // This is a placeholder - implement using Supabase Swift client
        // Documentation: https://supabase.com/docs/reference/swift/insert
        
        // Example implementation would be:
        // try await supabase.from("user_profiles").upsert(data)
        
        print("Profile saved to Supabase cloud (placeholder)")
    }

    func loadProfile(completion: @escaping (UserProfile?) -> Void = { _ in }) {
        // Try to load from cloud first if user is authenticated
        Task {
            let user = await supabaseService.getCurrentUser()
            if let user = user {
                do {
                    let cloudProfile = try await loadProfileFromCloud(userId: user.id)
                    if let cloudProfile = cloudProfile {
                        // Save cloud data locally for offline access
                        saveProfileLocally(cloudProfile)
                        await MainActor.run {
                            completion(cloudProfile)
                        }
                    } else {
                        // Fallback to local data
                        await MainActor.run {
                            completion(loadProfileLocally())
                        }
                    }
                } catch {
                    // Fallback to local data
                    await MainActor.run {
                        completion(loadProfileLocally())
                    }
                }
            } else {
                // For unauthenticated users, only use local storage
                await MainActor.run {
                    completion(loadProfileLocally())
                }
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
    
    private func loadProfileFromCloud(userId: String) async throws -> UserProfile? {
        // TODO: Replace with actual Supabase client implementation
        // This is a placeholder - implement using Supabase Swift client
        // Documentation: https://supabase.com/docs/reference/swift/select
        
        // Example implementation would be:
        // let response = try await supabase.from("user_profiles").select().eq("id", userId).single()
        // return UserProfile(from: response.data)
        
        print("Loading profile from Supabase cloud (placeholder)")
        return nil // Fallback to local for now
    }
    
    // Synchronous version for backward compatibility
    func loadProfile() -> UserProfile? {
        return loadProfileLocally()
    }
    
    /// Migrates local profile data to cloud when user upgrades from anonymous to authenticated
    func migrateLocalToCloud() {
        Task {
            let user = await supabaseService.getCurrentUser()
            if let user = user {
                if let localProfile = loadProfileLocally() {
                    try? await saveProfileToCloud(localProfile, userId: user.id)
                }
            }
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
        
        // Add Supabase if available (always available in this implementation)
        providers.append(.supabase)
        
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
        case .supabase:
            // Save to Supabase (existing saveProfile method handles this)
            saveProfile(currentProfile)
        case .cloudKit:
            // Save to CloudKit
            let cloudKitRepo = CloudKitUserProfileRepository()
            cloudKitRepo.saveProfile(currentProfile)
        }
        
        // Profile data migrated from \(from.displayName) to \(to.displayName)
    }
}
