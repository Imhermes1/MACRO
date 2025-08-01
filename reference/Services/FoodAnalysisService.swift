//
//  FoodAnalysisService.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: - Food Analysis Service
class FoodAnalysisService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        // Try multiple methods to retrieve API key with better error handling
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "AI_API_KEY") as? String, !apiKey.isEmpty {
            self.apiKey = apiKey
            print("✅ FoodAnalysisService: API key loaded successfully")
        } else if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path),
                  let apiKey = plist["AI_API_KEY"] as? String, !apiKey.isEmpty {
            self.apiKey = apiKey
            print("✅ FoodAnalysisService: API key loaded from Info.plist")
        } else {
            print("⚠️ Warning: AI_API_KEY not found in Info.plist or bundle")
            self.apiKey = ""
        }
    }
    
    func analyzeFood(input: String, inputType: String, image: UIImage? = nil) async throws -> [NutritionData] {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "AI API key not found. Please check that AI_API_KEY is set in your Info.plist file."])
        }
        
        let prompt = createFoodAnalysisPrompt(input: input, inputType: inputType, hasImage: image != nil)
        
        let requestBody = try createRequestBody(prompt: prompt, image: image)
        
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "AI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "AI", code: -3, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
        }
        
        return try parseNutritionResponse(data: data)
    }
    
    private func createFoodAnalysisPrompt(input: String, inputType: String, hasImage: Bool) -> String {
        var prompt = """
        You are an expert Australian nutritionist. The user provided the following food input: \"\(input)\"
        
        IMPORTANT GUIDELINES:
        - Correct any typos or speech recognition errors (e.g., 'Ifillet' → 'eye fillet', 'margheritsa' → 'margherita', 'domeinos' → 'dominos').
        - For restaurant foods (like Domino's, McDonald's, etc.), use their official Australian nutritional data.
        - For pizza slices, use standard slice sizes (typically 1/8 of a medium pizza, ~200-300 calories per slice).
        - For multiple items (e.g., "two slices"), multiply the nutrition values accordingly.
        - Split composite meals into individual food items.
        - Use Australian food standards (AUSNUT 2011-13), brands, and portion sizes.
        - For each item, return: description, calories, protein, carbs, fat, sugar, fibre, saturatedFat, sodium, cholesterol. If a value is unknown, set it to null.
        
        EXAMPLES:
        - "two slices of margherita pizza from dominos" → 2 separate items with multiplied nutrition
        - "large mcdonalds big mac meal" → separate items for burger, fries, drink
        
        Return ONLY a JSON array of items, each with:
        {
          "description": string,
          "calories": number,
          "protein": number,
          "carbs": number,
          "fat": number,
          "sugar": number or null,
          "fibre": number or null,
          "saturatedFat": number or null,
          "sodium": number or null,
          "cholesterol": number or null
        }
        """
        
        if hasImage {
            prompt += "\n- An image was provided. Identify all visible foods and estimate their portions and nutrition as above."
        }
        
        return prompt
    }
    
    private func createRequestBody(prompt: String, image: UIImage?) throws -> [String: Any] {
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64Image = imageData.base64EncodedString()
            return [
                "model": "gpt-4o-vision-preview",
                "messages": [
                    [
                        "role": "user",
                        "content": [
                            ["type": "text", "text": prompt],
                            ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                        ]
                    ]
                ],
                "max_tokens": 400
            ]
        } else {
            return [
                "model": "gpt-4.1-mini-2025-04-14",
                "messages": [
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": 400,
                "temperature": 0.2
            ]
        }
    }
    
    private func parseNutritionResponse(data: Data) throws -> [NutritionData] {
        let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = response?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "AI", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        // Extract JSON from the response content
        let jsonStart = content.firstIndex(of: "[")
        let jsonEnd = content.lastIndex(of: "]")
        
        guard let start = jsonStart, let end = jsonEnd else {
            throw NSError(domain: "AI", code: -5, userInfo: [NSLocalizedDescriptionKey: "No JSON array found in response"])
        }
        
        let jsonString = String(content[start...end])
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "AI", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON string"])
        }
        
        let nutritionArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] ?? []
        
        return nutritionArray.compactMap { item in
            guard let description = item["description"] as? String,
                  let calories = item["calories"] as? Double else {
                return nil
            }
            
            return NutritionData(
                calories: calories,
                protein: item["protein"] as? Double ?? 0,
                carbs: item["carbs"] as? Double ?? 0,
                fat: item["fat"] as? Double ?? 0,
                description: description,
                sugar: item["sugar"] as? Double,
                fibre: item["fibre"] as? Double,
                saturatedFat: item["saturatedFat"] as? Double,
                sodium: item["sodium"] as? Double,
                cholesterol: item["cholesterol"] as? Double
            )
        }
    }
} 