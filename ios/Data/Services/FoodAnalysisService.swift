import Foundation

/**
 * FoodAnalysisService - Processes food prompts from the main app chat
 * Provides intelligent food analysis when GitHub database doesn't have matches
 */
class FoodAnalysisService {
    
    /**
     * Analyze food prompt and return nutrition data
     */
    func analyzeFood(prompt: String) async throws -> NutritionData {
        print("🔍 Analyzing food prompt: \(prompt)")
        
        // Simple food analysis based on common patterns
        let analysis = analyzeFoodPrompt(prompt)
        
        return NutritionData(
            id: UUID(),
            name: analysis.name,
            calories: analysis.calories,
            protein: analysis.protein,
            carbs: analysis.carbs,
            fat: analysis.fat,
            fiber: analysis.fiber,
            sugar: analysis.sugar,
            sodium: analysis.sodium,
            confidence: analysis.confidence,
            source: "food_analysis"
        )
    }
    
    private struct FoodAnalysis {
        let name: String
        let calories: Double
        let protein: Double
        let carbs: Double
        let fat: Double
        let fiber: Double?
        let sugar: Double?
        let sodium: Double?
        let confidence: Double
    }
    
    /**
     * Analyze food prompt and estimate nutrition values
     */
    private func analyzeFoodPrompt(_ prompt: String) -> FoodAnalysis {
        let lowercased = prompt.lowercased()
        
        // Extract food name (remove quantities, cooking methods, etc.)
        let foodName = extractFoodName(from: prompt)
        
        // Estimate nutrition based on food type patterns
        var calories = 100.0
        var protein = 3.0
        var carbs = 15.0
        var fat = 3.0
        var fiber: Double? = 2.0
        var sugar: Double? = 5.0
        var sodium: Double? = 100.0
        var confidence = 0.6
        
        // Protein-rich foods
        if lowercased.contains("chicken") || lowercased.contains("beef") || lowercased.contains("fish") || lowercased.contains("egg") {
            calories = 200
            protein = 25
            carbs = 0
            fat = 10
            fiber = nil
            sugar = nil
            confidence = 0.8
        }
        // Fruits
        else if lowercased.contains("apple") || lowercased.contains("banana") || lowercased.contains("orange") || lowercased.contains("fruit") {
            calories = 60
            protein = 0.5
            carbs = 15
            fat = 0.2
            fiber = 3
            sugar = 12
            sodium = 1
            confidence = 0.7
        }
        // Vegetables
        else if lowercased.contains("broccoli") || lowercased.contains("carrot") || lowercased.contains("spinach") || lowercased.contains("vegetable") {
            calories = 25
            protein = 2
            carbs = 5
            fat = 0.1
            fiber = 3
            sugar = 3
            sodium = 20
            confidence = 0.7
        }
        // Grains/Rice/Pasta
        else if lowercased.contains("rice") || lowercased.contains("pasta") || lowercased.contains("bread") || lowercased.contains("oats") {
            calories = 130
            protein = 3
            carbs = 27
            fat = 0.5
            fiber = 1
            sugar = 1
            sodium = 2
            confidence = 0.7
        }
        // Dairy
        else if lowercased.contains("milk") || lowercased.contains("cheese") || lowercased.contains("yogurt") {
            calories = 150
            protein = 8
            carbs = 12
            fat = 8
            fiber = nil
            sugar = 12
            sodium = 100
            confidence = 0.7
        }
        
        // Adjust for portion size keywords
        if lowercased.contains("large") || lowercased.contains("big") {
            calories *= 1.5
            protein *= 1.5
            carbs *= 1.5
            fat *= 1.5
        } else if lowercased.contains("small") || lowercased.contains("little") {
            calories *= 0.7
            protein *= 0.7
            carbs *= 0.7
            fat *= 0.7
        }
        
        return FoodAnalysis(
            name: foodName,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            sodium: sodium,
            confidence: confidence
        )
    }
    
    /**
     * Extract clean food name from prompt
     */
    private func extractFoodName(from prompt: String) -> String {
        var name = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove common quantity words
        let quantityWords = ["one", "two", "three", "a", "an", "some", "large", "small", "medium", "cup", "bowl", "plate", "serving"]
        
        for word in quantityWords {
            name = name.replacingOccurrences(of: word, with: "", options: .caseInsensitive)
        }
        
        // Clean up extra spaces
        name = name.replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Capitalize first letter
        if !name.isEmpty {
            name = name.prefix(1).capitalized + name.dropFirst()
        }
        
        return name.isEmpty ? "Unknown Food" : name
    }
}