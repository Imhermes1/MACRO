//
//  NutritionData.swift
//  Calorie Tracker By Luke
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation

// MARK: - Nutrition Data Model
struct NutritionData: Codable {
    // MARK: - Constants
    private static let calorieConsistencyTolerancePercentage = 0.1
    private static let calorieConsistencyToleranceMinimum = 10.0
    private static let normalizationTolerancePercentage = 0.15
    private static let normalizationToleranceMinimum = 15.0
    private static let minimumReasonableCalories = 10.0
    
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let description: String
    // Expanded nutrition fields (optional)
    let sugar: Double?
    let fibre: Double?
    let saturatedFat: Double?
    let sodium: Double?
    let cholesterol: Double?
    
    // MARK: - Initialization with Validation
    init(calories: Double, protein: Double, carbs: Double, fat: Double, description: String, sugar: Double? = nil, fibre: Double? = nil, saturatedFat: Double? = nil, sodium: Double? = nil, cholesterol: Double? = nil) {
        // Validate and normalize the data
        let normalizedData = Self.normalizeNutritionData(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            description: description
        )
        
        self.calories = normalizedData.calories
        self.protein = normalizedData.protein
        self.carbs = normalizedData.carbs
        self.fat = normalizedData.fat
        self.description = normalizedData.description
        self.sugar = sugar
        self.fibre = fibre
        self.saturatedFat = saturatedFat
        self.sodium = sodium
        self.cholesterol = cholesterol
    }
}

// MARK: - Computed Properties
extension NutritionData {
    /// Total macronutrients in grams
    var totalMacros: Double {
        return protein + carbs + fat
    }
    
    /// Calories from protein (4 cal/g)
    var proteinCalories: Double {
        return protein * 4
    }
    
    /// Calories from carbs (4 cal/g)
    var carbCalories: Double {
        return carbs * 4
    }
    
    /// Calories from fat (9 cal/g)
    var fatCalories: Double {
        return fat * 9
    }
    
    /// Calculated total calories from macros
    var calculatedCalories: Double {
        return proteinCalories + carbCalories + fatCalories
    }
    
    /// Macro percentages
    var macroPercentages: (protein: Double, carbs: Double, fat: Double) {
        let total = calculatedCalories
        guard total > 0 else { return (0, 0, 0) }
        
        return (
            protein: (proteinCalories / total) * 100,
            carbs: (carbCalories / total) * 100,
            fat: (fatCalories / total) * 100
        )
    }
    
    /// Check if the nutrition data seems valid
    var isValid: Bool {
        return calories > 0 &&
               protein >= 0 &&
               carbs >= 0 &&
               fat >= 0 &&
               !description.isEmpty &&
               isCalorieConsistent
    }
    
    /// Check if this is estimated data (contains warning emoji)
    var isEstimated: Bool {
        return description.contains("⚠️")
    }
    
    /// Check if calories are consistent with macro calculations
    var isCalorieConsistent: Bool {
        let calculated = calculatedCalories
        let reported = calories
        let difference = abs(calculated - reported)
        let tolerance = max(calculated * Self.calorieConsistencyTolerancePercentage, Self.calorieConsistencyToleranceMinimum)
        return difference <= tolerance
    }
    
    /// Get the most accurate calorie value (calculated vs reported)
    var accurateCalories: Double {
        if isCalorieConsistent {
            return calories // Use reported if consistent
        } else {
            return calculatedCalories // Use calculated if inconsistent
        }
    }
    
    /// Get confidence level for this nutrition data
    var confidenceLevel: ConfidenceLevel {
        if isEstimated {
            return .low
        } else if isCalorieConsistent {
            return .high
        } else {
            return .medium
        }
    }
    
    enum ConfidenceLevel {
        case low, medium, high
        
        var description: String {
            switch self {
            case .low: return "Estimated"
            case .medium: return "Validated"
            case .high: return "Accurate"
            }
        }
        
        var color: String {
            switch self {
            case .low: return "yellow"
            case .medium: return "orange"
            case .high: return "green"
            }
        }
    }
}

// MARK: - Data Normalization and Validation
extension NutritionData {
    /// Normalize nutrition data to ensure consistency
    static func normalizeNutritionData(
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        description: String
    ) -> (calories: Double, protein: Double, carbs: Double, fat: Double, description: String) {
        
        var normalizedCalories = calories
        var normalizedProtein = max(0, protein)
        var normalizedCarbs = max(0, carbs)
        var normalizedFat = max(0, fat)
        var normalizedDescription = description
        
        // Calculate expected calories from macros
        let calculatedCalories = (normalizedProtein * 4) + (normalizedCarbs * 4) + (normalizedFat * 9)
        
        // Check for significant calorie inconsistency
        let calorieDifference = abs(calculatedCalories - normalizedCalories)
        let tolerance = max(calculatedCalories * Self.normalizationTolerancePercentage, Self.normalizationToleranceMinimum)
        
        if calorieDifference > tolerance {
            // If the difference is too large, prefer calculated calories
            normalizedCalories = calculatedCalories
            
            // Add warning to description if not already present
            if !normalizedDescription.contains("⚠️") {
                normalizedDescription = "⚠️ \(normalizedDescription) (calories adjusted for consistency)"
            }
        }
        
        // Ensure minimum reasonable values
        if normalizedCalories < Self.minimumReasonableCalories && (normalizedProtein > 0 || normalizedCarbs > 0 || normalizedFat > 0) {
            normalizedCalories = max(calculatedCalories, Self.minimumReasonableCalories)
        }
        
        // Round to reasonable precision
        normalizedCalories = round(normalizedCalories)
        normalizedProtein = round(normalizedProtein * 10) / 10
        normalizedCarbs = round(normalizedCarbs * 10) / 10
        normalizedFat = round(normalizedFat * 10) / 10
        
        return (
            calories: normalizedCalories,
            protein: normalizedProtein,
            carbs: normalizedCarbs,
            fat: normalizedFat,
            description: normalizedDescription
        )
    }
    
    /// Create nutrition data with automatic validation
    static func validated(
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        description: String
    ) -> NutritionData {
        let normalized = normalizeNutritionData(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            description: description
        )
        
        return NutritionData(
            calories: normalized.calories,
            protein: normalized.protein,
            carbs: normalized.carbs,
            fat: normalized.fat,
            description: normalized.description
        )
    }
}

// MARK: - Formatting Helpers
extension NutritionData {
    /// Formatted string for displaying calories
    var formattedCalories: String {
        return "\(Int(calories)) cal"
    }
    
    /// Formatted string for displaying macros
    var formattedMacros: String {
        return "P: \(Int(protein))g | C: \(Int(carbs))g | F: \(Int(fat))g"
    }
    
    /// Create a summary string
    var summary: String {
        let percentages = macroPercentages
        return """
        \(description)
        \(formattedCalories)
        \(formattedMacros)
        (P: \(Int(percentages.protein))% | C: \(Int(percentages.carbs))% | F: \(Int(percentages.fat))%)
        """
    }
}

// MARK: - Factory Methods
extension NutritionData {
    /// Create nutrition data with estimated values
    static func estimated(for foodDescription: String, calories: Double = 250) -> NutritionData {
        return NutritionData(
            calories: calories,
            protein: 15,
            carbs: 35,
            fat: 12,
            description: "⚠️ \(foodDescription) (estimated values)"
        )
    }
    
    /// Create empty nutrition data
    static var empty: NutritionData {
        return NutritionData(
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            description: "No data"
        )
    }
}

// MARK: - Enhanced Australian Nutrition Data
struct AustralianNutritionData: Codable {
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let description: String
    let confidence: Double
    let australianSpecific: Bool
    var subItems: [AustralianNutritionData]? // <-- Added for composite meals
    // Expanded nutrition fields (optional)
    let sugar: Double?
    let fibre: Double?
    let saturatedFat: Double?
    let sodium: Double?
    let cholesterol: Double?
    
    // Convert to standard NutritionData
    func toNutritionData() -> NutritionData {
        return NutritionData(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            description: description
        )
    }
}

// MARK: - Accuracy Confidence Scoring
struct AccuracyScoring {
    static func calculateConfidence(
        hasAustralianBrand: Bool,
        hasSpecificPortion: Bool,
        hasCookingMethod: Bool,
        inputClarity: Double
    ) -> Double {
        var confidence = 0.5 // Base confidence
        
        if hasAustralianBrand { confidence += 0.2 }
        if hasSpecificPortion { confidence += 0.15 }
        if hasCookingMethod { confidence += 0.1 }
        confidence += inputClarity * 0.05
        
        return min(confidence, 1.0)
    }
    
    static func getAccuracyLevel(_ confidence: Double) -> String {
        switch confidence {
        case 0.9...1.0:
            return "Very High"
        case 0.8..<0.9:
            return "High"
        case 0.7..<0.8:
            return "Good"
        case 0.6..<0.7:
            return "Fair"
        default:
            return "Low"
        }
    }
}

// MARK: - Nutrition Advice Model
struct NutritionAdvice: Codable {
    let insight: String
    let suggestion: String
    let mealIdea: String
    let motivation: String
    let macroBalance: String
}

// MARK: - Sample Data (for previews/testing)
#if DEBUG
extension NutritionData {
    static let sampleData = NutritionData(
        calories: 550,
        protein: 25,
        carbs: 45,
        fat: 30,
        description: "Big Mac"
    )
    
    static let sampleMeal = NutritionData(
        calories: 1100,
        protein: 45,
        carbs: 120,
        fat: 55,
        description: "Big Mac Meal with Large Fries and Coke"
    )
    
    static let sampleHealthy = NutritionData(
        calories: 350,
        protein: 30,
        carbs: 15,
        fat: 20,
        description: "Grilled Chicken Salad"
    )
    
    static let sampleEstimated = NutritionData.estimated(for: "Homemade Pizza", calories: 800)
}
#endif
