import Foundation

/**
 * GitHubNutrientService - Downloads and processes nutrition data from GitHub releases
 * Accesses https://github.com/Imhermes1/Macro-Database/releases/tag/Release
 * Specifically uses "Release.2.-.Nutrient.file.json"
 */
class GitHubNutrientService {
    
    private let githubReleaseURL = "https://github.com/Imhermes1/Macro-Database/releases/download/Release/Release.2.-.Nutrient.file.json"
    private let localCacheKey = "github_nutrient_data"
    private var cachedNutrients: [NutrientItem] = []
    
    struct NutrientItem: Codable {
        let id: String
        let name: String
        let calories: Double?
        let protein: Double?
        let carbs: Double?
        let fat: Double?
        let fiber: Double?
        let sugar: Double?
        let sodium: Double?
        
        // Convert to NutritionData format
        func toNutritionData() -> NutritionData {
            return NutritionData(
                id: UUID(),
                name: name,
                calories: calories ?? 0.0,
                protein: protein ?? 0.0,
                carbs: carbs ?? 0.0,
                fat: fat ?? 0.0,
                fiber: fiber,
                sugar: sugar,
                sodium: sodium,
                confidence: 0.8,
                source: "github_database"
            )
        }
    }
    
    /**
     * Download nutrient database from GitHub release
     */
    func downloadNutrientDatabase(progressCallback: @escaping (Double) -> Void) async throws -> Bool {
        guard let url = URL(string: githubReleaseURL) else {
            throw URLError(.badURL)
        }
        
        print("🔄 Downloading nutrient database from GitHub...")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Parse the JSON data
        do {
            let nutrients = try JSONDecoder().decode([NutrientItem].self, from: data)
            self.cachedNutrients = nutrients
            
            // Cache locally
            if let encoded = try? JSONEncoder().encode(nutrients) {
                UserDefaults.standard.set(encoded, forKey: localCacheKey)
            }
            
            progressCallback(1.0)
            print("✅ Successfully downloaded \(nutrients.count) nutrients")
            return true
            
        } catch {
            print("❌ Failed to parse nutrient data: \(error)")
            throw error
        }
    }
    
    /**
     * Search for nutrients matching the food prompt
     */
    func searchNutrients(for prompt: String) async throws -> NutritionData? {
        // Load cached data if not already loaded
        if cachedNutrients.isEmpty {
            loadCachedNutrients()
        }
        
        // If still empty, try to download
        if cachedNutrients.isEmpty {
            let _ = try await downloadNutrientDatabase { _ in }
        }
        
        // Search for matching nutrient
        let searchTerms = prompt.lowercased().components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
        
        for nutrient in cachedNutrients {
            let nutrientName = nutrient.name.lowercased()
            
            // Check if any search term matches the nutrient name
            for term in searchTerms {
                if !term.isEmpty && nutrientName.contains(term) {
                    print("🔍 Found nutrient match: \(nutrient.name)")
                    return nutrient.toNutritionData()
                }
            }
        }
        
        print("❌ No nutrient match found for: \(prompt)")
        return nil
    }
    
    /**
     * Load cached nutrients from UserDefaults
     */
    private func loadCachedNutrients() {
        guard let data = UserDefaults.standard.data(forKey: localCacheKey),
              let nutrients = try? JSONDecoder().decode([NutrientItem].self, from: data) else {
            return
        }
        
        self.cachedNutrients = nutrients
        print("📱 Loaded \(nutrients.count) cached nutrients")
    }
    
    /**
     * Check if we have cached nutrient data
     */
    func hasCachedData() -> Bool {
        if !cachedNutrients.isEmpty {
            return true
        }
        
        loadCachedNutrients()
        return !cachedNutrients.isEmpty
    }
}