//
//  AIService.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: - AI Service Coordinator
@MainActor
class AIService: ObservableObject {
    // Lazy-load services only when needed to reduce memory footprint
    // These services are instantiated only on demand when their methods are called
    private lazy var foodAnalysisService: FoodAnalysisService = {
        print("🤖 AIService: Initializing FoodAnalysisService")
        return FoodAnalysisService()
    }()
    
    private lazy var chatService: ChatService = {
        print("🤖 AIService: Initializing ChatService")
        return ChatService()
    }()
    
    private lazy var imageAnalysisService: ImageAnalysisService = {
        print("🤖 AIService: Initializing ImageAnalysisService")
        return ImageAnalysisService()
    }()
    
    private lazy var pdfAnalysisService: PDFAnalysisService = {
        print("🤖 AIService: Initializing PDFAnalysisService")
        return PDFAnalysisService()
    }()
    
    deinit {
        print("🧹 AIService deinitialized")
    }
    
    // MARK: - Food Analysis
    func analyzeFood(input: String, inputType: String, image: UIImage? = nil) async throws -> [NutritionData] {
        let service = self.foodAnalysisService
        let result = try await service.analyzeFood(input: input, inputType: inputType, image: image)
        service.cleanup()
        return result
    }
    
    // MARK: - Chat Services
    func sendMessage(_ message: String, context: ChatContext) async throws -> String {
        let service = self.chatService
        let result = try await service.sendMessage(message, context: context)
        service.cleanup()
        return result
    }
    
    func generateMealPlan(preferences: MealPreferences) async throws -> MealPlan {
        let service = self.chatService
        let result = try await service.generateMealPlan(preferences: preferences)
        service.cleanup()
        return result
    }
    
    // MARK: - Image Analysis
    func analyzeImage(_ image: UIImage) async throws -> [NutritionData] {
        let service = self.imageAnalysisService
        let result = try await service.analyzeImage(image)
        service.cleanup()
        return result
    }
    
    // MARK: - PDF Analysis
    func analyzePDF(_ pdfData: Data) async throws -> PDFAnalysisResult {
        let service = self.pdfAnalysisService
        let result = try await service.analyzePDF(pdfData)
        service.cleanup()
        return result
    }
    
    func extractNutritionFromPDF(_ pdfData: Data) async throws -> [NutritionData] {
        let service = self.pdfAnalysisService
        let result = try await service.extractNutritionFromPDF(pdfData)
        service.cleanup()
        return result
    }
}

// Extend service classes with no-op cleanup() methods if they don't already have one
extension FoodAnalysisService {
    func cleanup() {
        // Add cleanup logic here if holding large objects
    }
}

extension ChatService {
    func cleanup() {
        // Add cleanup logic here if holding large objects
    }
}

extension ImageAnalysisService {
    func cleanup() {
        // Add cleanup logic here if holding large objects
    }
}

extension PDFAnalysisService {
    func cleanup() {
        // Add cleanup logic here if holding large objects
    }
}

// MARK: - Supporting Types
struct ChatContext {
    let userProfile: UserProfile
    let conversationHistory: [ChatMessage]
    let currentGoals: NutritionGoals
}

struct UserProfile {
    let age: Int
    let weight: Double
    let height: Double
    let activityLevel: ActivityLevel
    let dietaryRestrictions: [DietaryRestriction]
    let healthConditions: [HealthCondition]
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extremelyActive = "Extremely Active"
}

enum DietaryRestriction: String, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten Free"
    case dairyFree = "Dairy Free"
    case keto = "Keto"
    case paleo = "Paleo"
}

enum HealthCondition: String, CaseIterable {
    case diabetes = "Diabetes"
    case heartDisease = "Heart Disease"
    case highBloodPressure = "High Blood Pressure"
    case celiac = "Celiac Disease"
    case lactoseIntolerance = "Lactose Intolerance"
}

struct NutritionGoals {
    let calorieGoal: Double
    let proteinGoal: Double
    let carbGoal: Double
    let fatGoal: Double
    let weightGoal: WeightGoal
}

enum WeightGoal: String, CaseIterable {
    case lose = "Lose Weight"
    case maintain = "Maintain Weight"
    case gain = "Gain Weight"
}

struct MealPreferences {
    let cuisine: [CuisineType]
    let cookingTime: CookingTime
    let servings: Int
    let budget: Budget
}

enum CuisineType: String, CaseIterable {
    case australian = "Australian"
    case italian = "Italian"
    case asian = "Asian"
    case mediterranean = "Mediterranean"
    case mexican = "Mexican"
    case indian = "Indian"
}

enum CookingTime: String, CaseIterable {
    case quick = "Quick (< 15 min)"
    case medium = "Medium (15-30 min)"
    case slow = "Slow (> 30 min)"
}

enum Budget: String, CaseIterable {
    case budget = "Budget Friendly"
    case moderate = "Moderate"
    case premium = "Premium"
}

struct MealPlan {
    let meals: [Meal]
    let totalCalories: Double
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double
    let shoppingList: [ShoppingItem]
    
    var description: String {
        let mealDescriptions = meals.map { meal in
            "• \(meal.name) (\(Int(meal.nutrition.calories)) cal)"
        }.joined(separator: "\n")
        
        return """
        Your personalised meal plan:
        
        \(mealDescriptions)
        
        Total: \(Int(totalCalories)) calories, \(Int(totalProtein))g protein, \(Int(totalCarbs))g carbs, \(Int(totalFat))g fat
        """
    }
}

struct Meal {
    let name: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let nutrition: NutritionData
    let prepTime: Int
    let cookTime: Int
    let difficulty: Difficulty
}

struct Ingredient {
    let name: String
    let amount: Double
    let unit: String
}

enum Difficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

struct ShoppingItem {
    let name: String
    let amount: Double
    let unit: String
    let category: ShoppingCategory
}

enum ShoppingCategory: String, CaseIterable {
    case produce = "Produce"
    case meat = "Meat & Seafood"
    case dairy = "Dairy"
    case pantry = "Pantry"
    case frozen = "Frozen"
}

struct PDFAnalysisResult {
    let extractedText: String
    let nutritionData: [NutritionData]
    let recommendations: [String]
    let professionalNotes: [String]
}
