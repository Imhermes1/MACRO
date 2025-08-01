//
//  NutritionService.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Unified Nutrition Service
@MainActor
class NutritionService: ObservableObject {
    // Lazy-load services only when needed to reduce memory footprint
    private lazy var foodDatabaseService: FoodDatabaseService = {
        print("🍎 NutritionService: Initializing FoodDatabaseService")
        return FoodDatabaseService()
    }()
    
    private lazy var barcodeService: BarcodeService = {
        print("🍎 NutritionService: Initializing BarcodeService")
        return BarcodeService()
    }()
    
    private lazy var imageRecognitionService: ImageRecognitionService = {
        print("🍎 NutritionService: Initializing ImageRecognitionService")
        return ImageRecognitionService()
    }()
    
    // MARK: - Food Database
    func searchFoodDatabase(query: String) async throws -> [NutritionData] {
        return try await foodDatabaseService.searchFood(query: query)
    }
    
    func getFoodByBarcode(_ barcode: String) async throws -> NutritionData? {
        return try await barcodeService.getFoodByBarcode(barcode)
    }
    
    func analyzeImage(_ imageData: Data) async throws -> [NutritionData] {
        return try await imageRecognitionService.analyzeImage(imageData)
    }
    
    // MARK: - Australian Food Database
    func searchAustralianFoodDatabase(query: String) async throws -> [NutritionData] {
        return try await foodDatabaseService.searchAustralianFood(query: query)
    }
    
    // MARK: - External API
    func searchExternalAPI(query: String) async throws -> [NutritionData] {
        return try await foodDatabaseService.searchExternalAPI(query: query)
    }
    
    // MARK: - Unified Search
    func unifiedSearch(query: String) async throws -> [NutritionData] {
        var allResults: [NutritionData] = []
        
        // Search Australian database first
        let australianResults = try await searchAustralianFoodDatabase(query: query)
        allResults.append(contentsOf: australianResults)
        
        // Search external API
        let externalResults = try await searchExternalAPI(query: query)
        allResults.append(contentsOf: externalResults)
        
        // Remove duplicates and sort by relevance
        return removeDuplicatesAndSort(allResults)
    }
    
    private func removeDuplicatesAndSort(_ results: [NutritionData]) -> [NutritionData] {
        var uniqueResults: [NutritionData] = []
        var seenDescriptions: Set<String> = []
        
        for result in results {
            let normalizedDescription = result.description.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if !seenDescriptions.contains(normalizedDescription) {
                seenDescriptions.insert(normalizedDescription)
                uniqueResults.append(result)
            }
        }
        
        // Sort by relevance (Australian results first, then by calorie accuracy)
        return uniqueResults.sorted { first, second in
            let firstIsAustralian = first.description.contains("Australian") || first.description.contains("AUS")
            let secondIsAustralian = second.description.contains("Australian") || second.description.contains("AUS")
            
            if firstIsAustralian && !secondIsAustralian {
                return true
            } else if !firstIsAustralian && secondIsAustralian {
                return false
            } else {
                // Sort by calorie accuracy (non-zero calories first)
                let firstHasCalories = first.calories > 0
                let secondHasCalories = second.calories > 0
                
                if firstHasCalories && !secondHasCalories {
                    return true
                } else if !firstHasCalories && secondHasCalories {
                    return false
                } else {
                    return first.calories > second.calories
                }
            }
        }
    }
}

// MARK: - Food Database Service
class FoodDatabaseService {
    private let australianFoodDatabase = AustralianFoodDatabase()
    private let externalAPIService = ExternalAPIService()
    
    func searchFood(query: String) async throws -> [NutritionData] {
        return try await searchAustralianFood(query: query)
    }
    
    func searchAustralianFood(query: String) async throws -> [NutritionData] {
        return try await australianFoodDatabase.search(query: query)
    }
    
    func searchExternalAPI(query: String) async throws -> [NutritionData] {
        return try await externalAPIService.search(query: query)
    }
}

// MARK: - Australian Food Database
class AustralianFoodDatabase {
    func search(query: String) async throws -> [NutritionData] {
        // Simulated Australian food database search
        // In a real implementation, this would connect to AUSNUT 2011-13 database
        
        let australianFoods = [
            NutritionData(
                calories: 250,
                protein: 26,
                carbs: 0,
                fat: 15,
                description: "Australian Beef Eye Fillet (100g)",
                sugar: 0,
                fibre: 0,
                saturatedFat: 6,
                sodium: 60,
                cholesterol: 70
            ),
            NutritionData(
                calories: 160,
                protein: 2,
                carbs: 9,
                fat: 15,
                description: "Australian Avocado (100g)",
                sugar: 0.7,
                fibre: 6.7,
                saturatedFat: 2.1,
                sodium: 7,
                cholesterol: 0
            ),
            NutritionData(
                calories: 86,
                protein: 1.6,
                carbs: 20,
                fat: 0.1,
                description: "Australian Sweet Potato (100g)",
                sugar: 4.2,
                fibre: 3,
                saturatedFat: 0,
                sodium: 55,
                cholesterol: 0
            )
        ]
        
        let queryLower = query.lowercased()
        return australianFoods.filter { food in
            food.description.lowercased().contains(queryLower)
        }
    }
}

// MARK: - External API Service
class ExternalAPIService {
    func search(query: String) async throws -> [NutritionData] {
        // Simulated external API search
        // In a real implementation, this would connect to external nutrition APIs
        
        let externalFoods = [
            NutritionData(
                calories: 165,
                protein: 31,
                carbs: 0,
                fat: 3.6,
                description: "Chicken Breast (100g)",
                sugar: 0,
                fibre: 0,
                saturatedFat: 1.1,
                sodium: 74,
                cholesterol: 85
            ),
            NutritionData(
                calories: 111,
                protein: 2.6,
                carbs: 23,
                fat: 0.9,
                description: "Brown Rice (100g cooked)",
                sugar: 0.4,
                fibre: 1.8,
                saturatedFat: 0.2,
                sodium: 5,
                cholesterol: 0
            )
        ]
        
        let queryLower = query.lowercased()
        return externalFoods.filter { food in
            food.description.lowercased().contains(queryLower)
        }
    }
}

// MARK: - Barcode Service
class BarcodeService {
    func getFoodByBarcode(_ barcode: String) async throws -> NutritionData? {
        // Simulated barcode lookup
        // In a real implementation, this would connect to a barcode database
        
        let barcodeDatabase = [
            "9300605000000": NutritionData(
                calories: 250,
                protein: 26,
                carbs: 0,
                fat: 15,
                description: "Coles Australian Beef Mince (100g)",
                sugar: 0,
                fibre: 0,
                saturatedFat: 6,
                sodium: 60,
                cholesterol: 70
            ),
            "9300605000001": NutritionData(
                calories: 165,
                protein: 31,
                carbs: 0,
                fat: 3.6,
                description: "Woolworths Chicken Breast (100g)",
                sugar: 0,
                fibre: 0,
                saturatedFat: 1.1,
                sodium: 74,
                cholesterol: 85
            )
        ]
        
        return barcodeDatabase[barcode]
    }
}

// MARK: - Image Recognition Service
class ImageRecognitionService {
    func analyzeImage(_ imageData: Data) async throws -> [NutritionData] {
        // This would integrate with the ImageAnalysisService
        // For now, return empty array
        return []
    }
} 
