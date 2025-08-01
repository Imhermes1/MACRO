import Foundation
import UIKit

// MARK: - Nutrition Analysis Protocols

/// Core protocol for food analysis
protocol NutritionAnalyzer {
    func analyzeFood(_ input: FoodInput) async throws -> NutritionResult
}

/// Protocol for AI-powered analysis
protocol AIAnalyzer: NutritionAnalyzer {
    func generateFollowUp(for input: String, context: [ChatMessage]) async -> String
    func getPersonalizedAdvice(userHistory: [FoodEntry], goals: String) async throws -> NutritionAdvice
}

/// Protocol for database lookups
protocol DatabaseAnalyzer: NutritionAnalyzer {
    func searchFood(query: String) async throws -> [NutritionData]
    func findExactMatch(for query: String) -> NutritionData?
}

/// Protocol for image analysis
protocol ImageAnalyzer {
    func analyzeImage(_ image: UIImage) async throws -> NutritionResult
}

// MARK: - Input/Output Models

struct FoodInput {
    let text: String
    let inputType: InputType
    let image: UIImage?
    let context: AnalysisContext
    
    enum InputType: String, Codable {
        case speech, text, image, barcode
    }
    
    enum AnalysisContext {
        case quickLogging
        case detailedCoaching
        case recipeAnalysis
        case socialSharing
        case mealPlanning
    }
}

struct NutritionResult {
    let items: [NutritionData]
    let confidence: Double
    let source: AnalysisSource
    let isComposite: Bool
    let suggestions: [String]
    
    enum AnalysisSource: String {
        case ai = "AI Analysis"
        case database = "Food Database"
        case australian = "Australian Database"
        case api = "Nutrition API"
        case hybrid = "Multiple Sources"
    }
    
    /// Convert to AustralianNutritionData for backward compatibility
    func toAustralianNutritionData() -> AustralianNutritionData {
        if items.count > 1 {
            // Composite meal
            let totalCalories = items.reduce(0) { $0 + $1.calories }
            let totalProtein = items.reduce(0) { $0 + $1.protein }
            let totalCarbs = items.reduce(0) { $0 + $1.carbs }
            let totalFat = items.reduce(0) { $0 + $1.fat }
            let description = items.map { $0.description }.joined(separator: " and ")
            
            let subItems = items.map { item in
                AustralianNutritionData(
                    calories: item.calories,
                    protein: item.protein,
                    carbs: item.carbs,
                    fat: item.fat,
                    description: item.description,
                    confidence: confidence,
                    australianSpecific: source == .australian,
                    subItems: nil,
                    sugar: item.sugar,
                    fibre: item.fibre,
                    saturatedFat: item.saturatedFat,
                    sodium: item.sodium,
                    cholesterol: item.cholesterol
                )
            }
            
            return AustralianNutritionData(
                calories: totalCalories,
                protein: totalProtein,
                carbs: totalCarbs,
                fat: totalFat,
                description: description,
                confidence: confidence,
                australianSpecific: source == .australian,
                subItems: subItems,
                sugar: nil,
                fibre: nil,
                saturatedFat: nil,
                sodium: nil,
                cholesterol: nil
            )
        } else if let first = items.first {
            return AustralianNutritionData(
                calories: first.calories,
                protein: first.protein,
                carbs: first.carbs,
                fat: first.fat,
                description: first.description,
                confidence: confidence,
                australianSpecific: source == .australian,
                subItems: nil,
                sugar: first.sugar,
                fibre: first.fibre,
                saturatedFat: first.saturatedFat,
                sodium: first.sodium,
                cholesterol: first.cholesterol
            )
        } else {
            return AustralianNutritionData(
                calories: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
                description: "No data",
                confidence: 0.5,
                australianSpecific: false,
                subItems: nil,
                sugar: nil,
                fibre: nil,
                saturatedFat: nil,
                sodium: nil,
                cholesterol: nil
            )
        }
    }
}

// MARK: - Analysis Strategy

/// Strategy pattern for combining multiple analyzers
class NutritionAnalysisStrategy {
    private let analyzers: [NutritionAnalyzer]
    private let fallbackOrder: [AnalyzerType]
    
    enum AnalyzerType {
        case ai, database, api, australian
    }
    
    init(analyzers: [NutritionAnalyzer], fallbackOrder: [AnalyzerType] = [.australian, .ai, .database, .api]) {
        self.analyzers = analyzers
        self.fallbackOrder = fallbackOrder
    }
    
    func analyze(_ input: FoodInput) async throws -> NutritionResult {
        var lastError: Error?
        
        for analyzerType in fallbackOrder {
            if let analyzer = getAnalyzer(for: analyzerType) {
                do {
                    return try await analyzer.analyzeFood(input)
                } catch {
                    lastError = error
                    continue
                }
            }
        }
        
        throw lastError ?? NutritionError.noAnalyzersAvailable
    }
    
    private func getAnalyzer(for type: AnalyzerType) -> NutritionAnalyzer? {
        // This would be implemented based on your specific analyzer types
        return analyzers.first
    }
}

// MARK: - Errors

enum NutritionError: LocalizedError {
    case noAnalyzersAvailable
    case analysisTimeout
    case invalidInput
    case networkError
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .noAnalyzersAvailable:
            return "No nutrition analyzers are available"
        case .analysisTimeout:
            return "Analysis timed out"
        case .invalidInput:
            return "Invalid input provided"
        case .networkError:
            return "Network error occurred"
        case .apiKeyMissing:
            return "API key is missing"
        }
    }
}