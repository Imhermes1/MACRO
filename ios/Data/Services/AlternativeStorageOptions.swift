import Foundation

/**
 * AlternativeStorageOptions - Manages local storage options for nutrient data
 * Provides user option to download and cache nutrition files locally
 */
class AlternativeStorageOptions {
    
    private let localDataKey = "local_nutrition_cache"
    private let documentsDirectory: URL
    
    init() {
        self.documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /**
     * Cache nutrient data locally
     */
    func cacheNutrientData() async throws {
        print("💾 Caching nutrient data locally...")
        
        // Get the cached data from UserDefaults (set by GitHubNutrientService)
        guard let data = UserDefaults.standard.data(forKey: "github_nutrient_data") else {
            throw StorageError.noDataToCache
        }
        
        // Save to documents directory for persistent storage
        let fileURL = documentsDirectory.appendingPathComponent("nutrition_database.json")
        
        try data.write(to: fileURL)
        
        // Mark as locally available
        UserDefaults.standard.set(true, forKey: "has_local_nutrition_data")
        
        print("✅ Nutrient data cached locally at: \(fileURL.path)")
    }
    
    /**
     * Check if local nutrient data exists
     */
    func hasLocalData() -> Bool {
        return UserDefaults.standard.bool(forKey: "has_local_nutrition_data")
    }
    
    /**
     * Get local data file URL
     */
    func getLocalDataURL() -> URL? {
        guard hasLocalData() else { return nil }
        return documentsDirectory.appendingPathComponent("nutrition_database.json")
    }
    
    /**
     * Clear local nutrient data
     */
    func clearLocalData() throws {
        let fileURL = documentsDirectory.appendingPathComponent("nutrition_database.json")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        UserDefaults.standard.removeObject(forKey: "has_local_nutrition_data")
        UserDefaults.standard.removeObject(forKey: "github_nutrient_data")
        
        print("🗑️ Local nutrient data cleared")
    }
    
    /**
     * Get local data size
     */
    func getLocalDataSize() -> String {
        guard let fileURL = getLocalDataURL(),
              let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let fileSize = attributes[.size] as? Int64 else {
            return "0 KB"
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    /**
     * Export local data for sharing
     */
    func exportLocalData() throws -> URL? {
        guard let sourceURL = getLocalDataURL() else {
            throw StorageError.noLocalData
        }
        
        let tempURL = documentsDirectory.appendingPathComponent("macro_nutrition_export.json")
        
        try FileManager.default.copyItem(at: sourceURL, to: tempURL)
        
        return tempURL
    }
}

// MARK: - Storage Errors
enum StorageError: LocalizedError {
    case noDataToCache
    case noLocalData
    case fileOperationFailed
    
    var errorDescription: String? {
        switch self {
        case .noDataToCache:
            return "No nutrition data available to cache"
        case .noLocalData:
            return "No local nutrition data found"
        case .fileOperationFailed:
            return "File operation failed"
        }
    }
}