import Foundation
import Combine

/**
 * CloudNutrientService - iOS equivalent of Android AndroidNutritionService
 * 
 * Comprehensive nutrition analysis service matching Android functionality
 * Uses OpenAI exclusively (simplified from Android's multi-provider approach)
 * 
 * Key features matching Android:
 * - Text analysis with caching
 * - Image analysis placeholder
 * - Barcode lookup with fallbacks
 * - Recipe analysis with enhanced prompts
 * - State management and error handling
 */
@MainActor
class CloudNutrientService: ObservableObject {
    
    // MARK: - Constants (matching Android cache settings)
    
    private static let cacheExpirationMs: TimeInterval = 24 * 60 * 60 // 24 hours
    private static let barcodeCache = "barcode_"
    private static let analysisCache = "analysis_"
    private static let minConfidenceThreshold = 0.5
    
    // MARK: - Published Properties (matching Android state management)
    
    @Published var isLoading: Bool = false
    @Published var lastError: Error? = nil
    @Published var serviceState: ServiceState = .idle
    
    // MARK: - Private Properties
    
    private let simpleFoodAI = SimpleFoodAI()
    private var nutritionCache: [String: CachedNutritionData] = [:]
    
    // MARK: - Initialization
    
    init() {
        print("🚀 CloudNutrientService initialized with OpenAI integration")
    }
    
    // MARK: - Public API (matching Android AndroidNutritionService interface)
    
    /**
     * Analyze text input for nutrition information
     * Matches Android: analyzeTextInput
     */
    func analyzeTextInput(_ text: String) async -> Result<NutritionData, Error> {
        print("🔍 CloudNutrientService: Analyzing text input: \(text)")
        
        await setLoading(true)
        defer { Task { await setLoading(false) } }
        
        // Check cache first (matching Android behavior)
        let cacheKey = CloudNutrientService.analysisCache + text.lowercased()
        if let cachedResult = getCachedResult(cacheKey) {
            print("📱 Found analysis result in cache")
            await setServiceState(.success("Found in cache"))
            return .success(cachedResult)
        }
        
        // Perform OpenAI analysis
        await setServiceState(.analyzing("Analyzing with OpenAI"))
        
        if let result = await simpleFoodAI.analyzeFood(text) {
            // Cache the result (matching Android caching pattern)
            setCachedResult(cacheKey, result)
            await setServiceState(.success("Analysis complete"))
            await clearError()
            return .success(result)
        } else {
            let error = NSError(domain: "CloudNutrientService", code: -1, 
                              userInfo: [NSLocalizedDescriptionKey: "Failed to analyze food text"])
            await setError(error)
            return .failure(error)
        }
    }
    
    /**
     * Analyze image input for nutrition information
     * Matches Android: analyzeImageInput
     */
    func analyzeImageInput(_ imageData: Data, description: String = "") async -> Result<NutritionData, Error> {
        print("📸 CloudNutrientService: Image analysis requested")
        
        await setLoading(true)
        defer { Task { await setLoading(false) } }
        
        // For now, return error since we're focusing on text analysis with OpenAI
        let error = NSError(domain: "CloudNutrientService", code: -2, 
                           userInfo: [NSLocalizedDescriptionKey: "Image analysis not yet implemented"])
        await setError(error)
        return .failure(error)
    }
    
    /**
     * Look up nutrition data by barcode
     * Matches Android: lookupBarcode
     */
    func lookupBarcode(_ barcode: String) async -> Result<NutritionData, Error> {
        print("🔍 Looking up barcode: \(barcode)")
        
        await setLoading(true)
        defer { Task { await setLoading(false) } }
        
        // Check cache (matching Android behavior)
        let cacheKey = CloudNutrientService.barcodeCache + barcode
        if let cachedResult = getCachedResult(cacheKey) {
            print("📱 Found barcode in cache")
            await setServiceState(.success("Found in cache"))
            return .success(cachedResult)
        }
        
        // For now, return error since external barcode APIs aren't implemented yet
        let error = NSError(domain: "CloudNutrientService", code: -3, 
                           userInfo: [NSLocalizedDescriptionKey: "Barcode lookup not yet implemented"])
        await setError(error)
        return .failure(error)
    }
    
    /**
     * Analyze recipe for nutrition information
     * Matches Android: analyzeRecipe with enhanced prompting
     */
    func analyzeRecipe(_ recipe: String, servings: Int) async -> Result<NutritionData, Error> {
        print("🍳 Analyzing recipe for \(servings) servings")
        
        // Enhance recipe prompt for better AI analysis (matching Android approach)
        let enhancedPrompt = """
            Analyze this recipe and provide per-serving nutrition information for \(servings) servings total.
            
            Recipe:
            \(recipe)
            
            Please calculate nutrition values per single serving.
        """
        
        // Use the regular text analysis with enhanced prompt
        let result = await analyzeTextInput(enhancedPrompt)
        
        switch result {
        case .success(let nutritionData):
            // Update the nutrition data with recipe-specific information
            let updatedNutrition = createRecipeNutrition(from: nutritionData, recipe: recipe)
            return .success(updatedNutrition)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /**
     * Get nutrition history - matches Android functionality
     */
    func getNutritionHistory() async -> [NutritionData] {
        // For now, return empty array - would integrate with local storage
        return []
    }
    
    // MARK: - Private Helper Methods (matching Android implementation patterns)
    
    private func getCachedResult(_ key: String) -> NutritionData? {
        guard let cached = nutritionCache[key] else { return nil }
        
        // Check if expired (matching Android cache expiration)
        if Date().timeIntervalSince1970 > cached.expirationTime {
            nutritionCache.removeValue(forKey: key)
            return nil
        }
        
        return cached.data
    }
    
    private func setCachedResult(_ key: String, _ data: NutritionData) {
        let expirationTime = Date().timeIntervalSince1970 + CloudNutrientService.cacheExpirationMs
        nutritionCache[key] = CachedNutritionData(data: data, expirationTime: expirationTime)
        
        // Clean up old cache entries
        cleanupCache()
    }
    
    private func cleanupCache() {
        let now = Date().timeIntervalSince1970
        nutritionCache = nutritionCache.filter { $0.value.expirationTime > now }
    }
    
    private func createRecipeNutrition(from nutritionData: NutritionData, recipe: String) -> NutritionData {
        let recipeName = extractRecipeName(recipe)
        
        return NutritionData(
            id: nutritionData.id,
            name: recipeName,
            brand: nutritionData.brand,
            calories: nutritionData.calories,
            protein: nutritionData.protein,
            carbs: nutritionData.carbs,
            fat: nutritionData.fat,
            fiber: nutritionData.fiber,
            sugar: nutritionData.sugar,
            sodium: nutritionData.sodium,
            confidence: nutritionData.confidence,
            source: "recipe_analysis",
            barcode: nutritionData.barcode,
            servingSize: "1 serving",
            servingUnit: "serving",
            date: nutritionData.date,
            saturatedFat: nutritionData.saturatedFat,
            transFat: nutritionData.transFat,
            cholesterol: nutritionData.cholesterol,
            potassium: nutritionData.potassium,
            calcium: nutritionData.calcium,
            iron: nutritionData.iron,
            vitaminA: nutritionData.vitaminA,
            vitaminC: nutritionData.vitaminC,
            vitaminD: nutritionData.vitaminD,
            vitaminE: nutritionData.vitaminE,
            vitaminK: nutritionData.vitaminK,
            thiamine: nutritionData.thiamine,
            riboflavin: nutritionData.riboflavin,
            niacin: nutritionData.niacin,
            vitaminB6: nutritionData.vitaminB6,
            folate: nutritionData.folate,
            vitaminB12: nutritionData.vitaminB12,
            phosphorus: nutritionData.phosphorus,
            magnesium: nutritionData.magnesium,
            zinc: nutritionData.zinc,
            selenium: nutritionData.selenium,
            copper: nutritionData.copper,
            manganese: nutritionData.manganese,
            chromium: nutritionData.chromium,
            molybdenum: nutritionData.molybdenum,
            chloride: nutritionData.chloride
        )
    }
    
    private func extractRecipeName(_ recipe: String) -> String {
        let lines = recipe.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Recipe"
        return firstLine.count > 50 ? String(firstLine.prefix(47)) + "..." : firstLine
    }
    
    // MARK: - State Management Helpers (matching Android patterns)
    
    private func setLoading(_ loading: Bool) async {
        await MainActor.run {
            self.isLoading = loading
        }
    }
    
    private func setError(_ error: Error) async {
        await MainActor.run {
            self.lastError = error
            self.serviceState = .error(error)
        }
    }
    
    private func setServiceState(_ state: ServiceState) async {
        await MainActor.run {
            self.serviceState = state
        }
    }
    
    private func clearError() async {
        await MainActor.run {
            self.lastError = nil
        }
    }
}

// MARK: - Supporting Types (matching Android models)

/**
 * Service state enum matching Android state management
 */
enum ServiceState {
    case idle
    case analyzing(String)
    case success(String)
    case error(Error)
}

/**
 * Cached nutrition data structure matching Android caching
 */
private struct CachedNutritionData {
    let data: NutritionData
    let expirationTime: TimeInterval
}
