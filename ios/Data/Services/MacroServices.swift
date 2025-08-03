import Foundation
import SwiftUI
import Combine
import OSLog

// MARK: - Sendable Data Models  
// Following Apple's final pattern: defined in non-actor context

struct NutritionEntry: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let nutritionData: NutritionData
    let quantity: Double
    let unit: String
    let timestamp: Date
    let mealType: String
    
    var totalCalories: Double {
        nutritionData.calories * quantity
    }
    
    var totalProtein: Double {
        nutritionData.protein * quantity
    }
    
    var totalCarbs: Double {
        nutritionData.carbs * quantity
    }
    
    var totalFat: Double {
        nutritionData.fat * quantity
    }
    
    init(
        id: UUID = UUID(),
        nutritionData: NutritionData,
        quantity: Double,
        unit: String = "serving",
        timestamp: Date = Date(),
        mealType: String = "other"
    ) {
        self.id = id
        self.nutritionData = nutritionData
        self.quantity = quantity
        self.unit = unit
        self.timestamp = timestamp
        self.mealType = mealType
    }
}

// MARK: - Supporting Data Types

// MARK: - Supporting Data Types

struct FoodInput: Sendable {
    let text: String?
    let image: Data?
    let type: InputType
    let context: AnalysisContext
    
    enum InputType: String, CaseIterable, Sendable {
        case text = "text"
        case speech = "speech"
        case image = "image"
        case barcode = "barcode"
        case recipe = "recipe"
    }
}

struct NutritionResult: Sendable {
    let items: [NutritionData]
    let confidence: Double
    let source: DataSource
    let timestamp: Date
    let suggestions: [String]
    
    enum DataSource: String, Sendable {
        case ai = "ai"
        case database = "database"
        case api = "api"
        case manual = "manual"
    }
}

struct AIAnalysisResult: Sendable {
    let content: String
    let confidence: Double
    let metadata: [String: String]
}

struct AnalysisContext: Sendable {
    let mealType: String?
    let preferences: [String]
    let restrictions: [String]
    let timestamp: Date
    
    // Legacy enum-style access for backward compatibility
    var rawValue: String { mealType ?? "other" }
    var detailedCoaching: String { "detailed_coaching" }
    var quickLogging: String { "quick_logging" }
    var recipeAnalysis: String { "recipe_analysis" }
    var mealPlanning: String { "meal_planning" }
    var socialSharing: String { "social_sharing" }
}

// MARK: - Service Protocols

protocol NutritionServiceProtocol: ObservableObject {
    var isLoading: Bool { get }
    var lastError: Error? { get }
    var recentSearches: [String] { get }
    
    func analyzeFood(from input: FoodInput) async throws -> NutritionResult
    func searchFood(query: String) async throws -> [NutritionData]
    func getFoodByBarcode(_ barcode: String) async throws -> NutritionData?
    func saveNutritionEntry(_ entry: NutritionEntry) async throws
    func getNutritionHistory(for date: Date) async throws -> [NutritionEntry]
}

protocol AIServiceProtocol: ObservableObject {
    var isProcessing: Bool { get }
    var lastError: Error? { get }
    
    func analyzeText(_ text: String, context: AnalysisContext) async throws -> AIAnalysisResult
    func analyzeImage(_ imageData: Data, prompt: String) async throws -> AIAnalysisResult
    func generateResponse(for prompt: String, context: AnalysisContext) async throws -> String
}

protocol DatabaseServiceProtocol {
    nonisolated func save<T: Codable & Sendable>(_ object: T) async throws
    nonisolated func fetch<T: Codable & Sendable>(_ type: T.Type) async throws -> [T]
    nonisolated func delete<T: Codable & Sendable>(_ object: T) async throws
    nonisolated func deleteAll<T: Codable & Sendable>(_ type: T.Type) async throws
}

protocol CacheServiceProtocol {
    nonisolated func store<T: Codable & Sendable>(_ object: T, forKey key: String) async throws
    nonisolated func retrieve<T: Codable & Sendable>(_ type: T.Type, forKey key: String) async throws -> T?
    nonisolated func remove(forKey key: String) async throws
    nonisolated func clear() async throws
    nonisolated func size() async throws -> Int64
}

// MARK: - Service Implementations
// Note: Actual service implementations are in the Implementation/ folder
// This keeps the code modular and maintainable following iOS best practices

// MARK: - Error Types

enum NutritionServiceError: LocalizedError {
    case invalidInput(String)
    case notFound(String)
    case networkError(String)
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .notFound(let message):
            return "Not found: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        }
    }
}
