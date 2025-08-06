import Foundation
import Combine
// The UserProfile struct is defined in UserProfile.swift and available throughout the target—no import needed.

/**
 * UserProfileRepository - Enhanced profile management for iOS with analytics
 * Handles local storage of user profiles with weight tracking and analytics
 * 
 * This follows Apple's recommended local-first strategy for iOS apps.
 * Data is immediately saved locally and can be extended with cloud sync.
 */
@MainActor
class UserProfileRepository: ObservableObject {
    private let key = "user_profile"
    private let weightHistoryKey = "weight_history"
    private let defaults = UserDefaults.standard
    
    @Published var currentProfile: UserProfile?
    @Published var weightHistory: [WeightEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        self.currentProfile = loadProfileLocally()
        self.weightHistory = loadWeightHistoryLocally()
    }

    func saveProfile(_ profile: UserProfile) {
        isLoading = true
        errorMessage = nil
        
        // Check if weight changed to track history
        let weightChanged = currentProfile?.weight != profile.weight
        
        // Save locally first for immediate access
        saveProfileLocally(profile)
        
        // Update published property
        currentProfile = profile
        
        // Add weight entry if weight changed
        if weightChanged {
            addWeightEntry(weight: profile.weight, source: "profile_update")
        }
        
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
            "weight": profile.weight,
            "goalType": profile.goalType.rawValue,
            "activityLevel": profile.activityLevel.rawValue,
            "profileCompleted": profile.profileCompleted
        ]
        if let lastName = profile.lastName {
            dict["lastName"] = lastName
        }
        if let dob = profile.dob {
            dict["dob"] = dob
        }
        if let initialWeight = profile.initialWeight {
            dict["initialWeight"] = initialWeight
        }
        if let goalWeight = profile.goalWeight {
            dict["goalWeight"] = goalWeight
        }
        defaults.set(dict, forKey: key)
    }

    // MARK: - Weight History Management
    
    func addWeightEntry(weight: Float, notes: String? = nil, source: String = "manual") {
        guard let profile = currentProfile else { return }
        
        let entry = WeightEntry(
            userId: profile.id,
            weight: weight,
            notes: notes,
            source: source
        )
        
        weightHistory.insert(entry, at: 0) // Add to beginning for recent-first order
        saveWeightHistoryLocally()
        
        // Update current profile weight if this is a manual entry
        if source == "manual" {
            var updatedProfile = profile
            updatedProfile.weight = weight
            saveProfile(updatedProfile)
        }
    }
    
    func updateWeightEntry(_ entry: WeightEntry) {
        if let index = weightHistory.firstIndex(where: { $0.id == entry.id }) {
            weightHistory[index] = entry
            saveWeightHistoryLocally()
        }
    }
    
    func deleteWeightEntry(_ entry: WeightEntry) {
        weightHistory.removeAll { $0.id == entry.id }
        saveWeightHistoryLocally()
    }
    
    private func saveWeightHistoryLocally() {
        do {
            let data = try JSONEncoder().encode(weightHistory)
            defaults.set(data, forKey: weightHistoryKey)
        } catch {
            print("Failed to save weight history: \(error)")
        }
    }
    
    private func loadWeightHistoryLocally() -> [WeightEntry] {
        guard let data = defaults.data(forKey: weightHistoryKey) else { return [] }
        
        do {
            return try JSONDecoder().decode([WeightEntry].self, from: data)
        } catch {
            print("Failed to load weight history: \(error)")
            return []
        }
    }

    // MARK: - Analytics
    
    func getProgressAnalytics() -> UserProgressAnalytics? {
        guard let profile = currentProfile else { return nil }
        
        let totalEntries = weightHistory.count
        let currentWeight = profile.weight
        let initialWeight = profile.initialWeight
        let goalWeight = profile.goalWeight
        
        // Calculate total change
        let totalChange = initialWeight != nil ? currentWeight - initialWeight! : nil
        
        // Calculate goal progress
        var goalProgressPercent: Float? = nil
        if let initial = initialWeight, let goal = goalWeight {
            let totalGoalDistance = initial - goal
            let currentProgress = initial - currentWeight
            goalProgressPercent = totalGoalDistance != 0 ? (currentProgress / totalGoalDistance) * 100 : 0
        }
        
        // Calculate average weekly change
        var avgWeeklyChange: Float? = nil
        if let firstEntry = weightHistory.last, // oldest entry
           let initial = initialWeight {
            let daysSinceStart = Calendar.current.dateComponents([.day], from: firstEntry.recordedAt, to: Date()).day ?? 0
            let weeksSinceStart = Float(max(daysSinceStart, 1)) / 7.0
            avgWeeklyChange = totalChange != nil ? totalChange! / weeksSinceStart : nil
        }
        
        // Calculate BMI
        let currentBMI = profile.height > 0 ? currentWeight / ((profile.height / 100) * (profile.height / 100)) : nil
        
        return UserProgressAnalytics(
            currentWeight: currentWeight,
            initialWeight: initialWeight,
            goalWeight: goalWeight,
            totalChange: totalChange,
            goalProgressPercent: goalProgressPercent,
            avgWeeklyChange: avgWeeklyChange,
            daysTracking: weightHistory.isEmpty ? 0 : Calendar.current.dateComponents([.day], from: weightHistory.last!.recordedAt, to: Date()).day ?? 0,
            totalEntries: totalEntries,
            currentBMI: currentBMI
        )
    }
    
    func getWeightTrend(daysBack: Int = 30) -> [WeightEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) ?? Date()
        return weightHistory.filter { $0.recordedAt >= cutoffDate }
    }
    
    func getRecentWeightEntries(limit: Int = 10) -> [WeightEntry] {
        return Array(weightHistory.prefix(limit))
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
        let initialWeight = dict["initialWeight"] as? Float
        let goalWeight = dict["goalWeight"] as? Float
        let goalTypeRaw = dict["goalType"] as? String ?? GoalType.maintainWeight.rawValue
        let activityLevelRaw = dict["activityLevel"] as? String ?? ActivityLevel.moderate.rawValue
        let profileCompleted = dict["profileCompleted"] as? Bool ?? false
        
        let goalType = GoalType(rawValue: goalTypeRaw) ?? .maintainWeight
        let activityLevel = ActivityLevel(rawValue: activityLevelRaw) ?? .moderate
        
        return UserProfile(
            firstName: firstName,
            lastName: lastName,
            age: age,
            dob: dob,
            height: height,
            weight: weight,
            initialWeight: initialWeight,
            goalWeight: goalWeight,
            goalType: goalType,
            activityLevel: activityLevel,
            profileCompleted: profileCompleted,
            id: id
        )
    }
    
    func clearProfile() {
        // Clear UserDefaults storage
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: weightHistoryKey)
        
        // Clear published properties immediately
        currentProfile = nil
        weightHistory = []
        isLoading = false
        errorMessage = nil
        
        // Force UserDefaults sync
        defaults.synchronize()
        
        print("🗑️ UserProfileRepository: All profile data cleared")
    }
    
    var hasProfile: Bool {
        return currentProfile != nil || defaults.dictionary(forKey: key) != nil
    }
    
    // MARK: - Profile Updates
    
    func updateProfile(
        firstName: String? = nil, 
        lastName: String? = nil, 
        age: Int? = nil, 
        height: Float? = nil, 
        weight: Float? = nil,
        goalWeight: Float? = nil,
        goalType: GoalType? = nil,
        activityLevel: ActivityLevel? = nil
    ) {
        guard let current = currentProfile else { return }
        
        let updated = UserProfile(
            firstName: firstName ?? current.firstName,
            lastName: lastName ?? current.lastName,
            age: age ?? current.age,
            dob: current.dob,
            height: height ?? current.height,
            weight: weight ?? current.weight,
            initialWeight: current.initialWeight,
            goalWeight: goalWeight ?? current.goalWeight,
            goalType: goalType ?? current.goalType,
            activityLevel: activityLevel ?? current.activityLevel,
            profileCompleted: current.profileCompleted,
            id: current.id
        )
        
        saveProfile(updated)
    }
    
    func markProfileCompleted() {
        guard let current = currentProfile else { return }
        
        let updated = UserProfile(
            firstName: current.firstName,
            lastName: current.lastName,
            age: current.age,
            dob: current.dob,
            height: current.height,
            weight: current.weight,
            initialWeight: current.initialWeight,
            goalWeight: current.goalWeight,
            goalType: current.goalType,
            activityLevel: current.activityLevel,
            profileCompleted: true,
            id: current.id
        )
        
        saveProfile(updated)
    }
    
    func setInitialWeight(_ weight: Float? = nil) {
        guard let current = currentProfile else { return }
        
        let weightToSet = weight ?? current.weight
        let updated = UserProfile(
            firstName: current.firstName,
            lastName: current.lastName,
            age: current.age,
            dob: current.dob,
            height: current.height,
            weight: current.weight,
            initialWeight: weightToSet,
            goalWeight: current.goalWeight,
            goalType: current.goalType,
            activityLevel: current.activityLevel,
            profileCompleted: current.profileCompleted,
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

