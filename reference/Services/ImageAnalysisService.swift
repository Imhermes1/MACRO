//
//  ImageAnalysisService.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: - Image Analysis Service
class ImageAnalysisService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        self.apiKey = Bundle.main.infoDictionary?["AI_API_KEY"] as? String ?? ""
    }
    
    func analyzeImage(_ image: UIImage) async throws -> [NutritionData] {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "AI API key not found"])
        }
        
        let prompt = createImageAnalysisPrompt()
        let requestBody = try createImageRequestBody(prompt: prompt, image: image)
        
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
    
    private func createImageAnalysisPrompt() -> String {
        return """
        You are an expert Australian nutritionist analyzing a food image. Identify all visible foods and estimate their nutrition values.
        
        IMPORTANT GUIDELINES:
        - Identify all foods visible in the image
        - Estimate portion sizes based on common Australian serving sizes
        - Use Australian food standards (AUSNUT 2011-13)
        - For restaurant foods, use their official Australian nutritional data
        - For each item, return: description, calories, protein, carbs, fat, sugar, fibre, saturatedFat, sodium, cholesterol
        - If a value is unknown, set it to null
        
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
    }
    
    private func createImageRequestBody(prompt: String, image: UIImage) throws -> [String: Any] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "AI", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
        }
        
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
            "max_tokens": 600
        ]
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