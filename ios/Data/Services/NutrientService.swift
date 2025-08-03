import Foundation
import Combine

/**
 * NutrientService - Main nutrition service coordinator
 * Orchestrates GitHub database, food analysis, and local storage
 * Processes food prompts from the main app chat
 */
@MainActor
class NutrientService: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var lastError: String? = nil
    @Published var searchResults: [NutritionData] = []
    @Published var recentAnalyses: [NutritionData] = []
    
    // Services
    private let githubService = GitHubNutrientService()
    private let analysisService = FoodAnalysisService()
    private let storageService = AlternativeStorageOptions()
    
    // Advanced AI-powered cloud service (disabled for now due to import issues)
    // private let cloudService = CloudNutrientService()
    
    /**
     * Enhanced food prompt processing with AI fallback
     */
    func processFoodPrompt(_ prompt: String) async -> NutritionData? {
        print("🍽️ Processing food prompt: \(prompt)")
        
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // Try GitHub service first
            if let result = try await githubService.searchNutrients(for: prompt) {
                await addToRecentAnalyses(result)
                return result
            }
            
            // Fallback to direct analysis
            let result = try await analysisService.analyzeFood(prompt: prompt)
            await addToRecentAnalyses(result)
            return result
            
        } catch {
            lastError = error.localizedDescription
            print("❌ Failed to process food prompt: \(error)")
            return nil
        }
    }
    
    /**
     * Search nutrition database
     */
    func searchNutrition(query: String) async -> [NutritionData] {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            if let result = try await githubService.searchNutrients(for: query) {
                let results = [result]
                searchResults = results
                return results
            } else {
                searchResults = []
                return []
            }
            
        } catch {
            lastError = error.localizedDescription
            searchResults = []
            return []
        }
    }
    
    /**
     * Download nutrition database locally
     */
    func downloadNutritionDatabase() async -> Bool {
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            let success = try await githubService.downloadNutrientDatabase { progress in
                // Progress callback - could be used to update UI
            }
            
            if success {
                try await storageService.cacheNutrientData()
            }
            
            return success
            
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }
    
    /**
     * Check if local nutrition data is available
     */
    func hasLocalNutritionData() -> Bool {
        return storageService.hasLocalData()
    }
    
    /**
     * Get local database info
     */
    func getLocalDatabaseInfo() -> (hasData: Bool, size: String) {
        return (storageService.hasLocalData(), storageService.getLocalDataSize())
    }
    
    /**
     * Clear local nutrition data
     */
    func clearLocalData() throws {
        try storageService.clearLocalData()
    }
    
    /**
     * Export nutrition data for sharing
     */
    func exportNutritionData() throws -> URL? {
        return try storageService.exportLocalData()
    }
    
    // MARK: - Private helpers
    
    private func addToRecentAnalyses(_ nutrition: NutritionData) async {
        recentAnalyses.insert(nutrition, at: 0)
        
        // Keep only last 10 analyses
        if recentAnalyses.count > 10 {
            recentAnalyses = Array(recentAnalyses.prefix(10))
        }
    }
}