//
//  PDFAnalysisService.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation
import PDFKit

// MARK: - PDF Analysis Service
class PDFAnalysisService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        self.apiKey = Bundle.main.infoDictionary?["AI_API_KEY"] as? String ?? ""
    }
    
    func analyzePDF(_ pdfData: Data) async throws -> PDFAnalysisResult {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "AI API key not found"])
        }
        
        let extractedText = try extractTextFromPDF(pdfData)
        let prompt = createPDFAnalysisPrompt(text: extractedText)
        let requestBody = createPDFRequestBody(prompt: prompt)
        
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
        
        return try parsePDFAnalysisResponse(data: data, extractedText: extractedText)
    }
    
    func extractNutritionFromPDF(_ pdfData: Data) async throws -> [NutritionData] {
        let result = try await analyzePDF(pdfData)
        return result.nutritionData
    }
    
    private func extractTextFromPDF(_ pdfData: Data) throws -> String {
        guard let pdfDocument = PDFDocument(data: pdfData) else {
            throw NSError(domain: "PDF", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PDF document"])
        }
        
        var extractedText = ""
        
        for i in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: i) {
                if let pageContent = page.string {
                    extractedText += pageContent + "\n"
                }
            }
        }
        
        return extractedText
    }
    
    private func createPDFAnalysisPrompt(text: String) -> String {
        return """
        You are an expert Australian nutritionist analyzing a professional document. Extract nutrition information and provide recommendations.
        
        DOCUMENT TEXT:
        \(text)
        
        Please analyze this document and return a JSON object with:
        {
          "nutritionData": [
            {
              "description": "Food item description",
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
          ],
          "recommendations": [
            "Recommendation 1",
            "Recommendation 2"
          ],
          "professionalNotes": [
            "Professional note 1",
            "Professional note 2"
          ]
        }
        
        Focus on:
        - Extracting any nutrition data mentioned
        - Identifying dietary recommendations
        - Highlighting professional insights
        - Converting any measurements to Australian standards
        """
    }
    
    private func createPDFRequestBody(prompt: String) -> [String: Any] {
        return [
            "model": "gpt-4.1-mini-2025-04-14",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 1000,
            "temperature": 0.3
        ]
    }
    
    private func parsePDFAnalysisResponse(data: Data, extractedText: String) throws -> PDFAnalysisResult {
        let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = response?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "AI", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        // Extract JSON from the response content
        let jsonStart = content.firstIndex(of: "{")
        let jsonEnd = content.lastIndex(of: "}")
        
        guard let start = jsonStart, let end = jsonEnd else {
            throw NSError(domain: "AI", code: -5, userInfo: [NSLocalizedDescriptionKey: "No JSON object found in response"])
        }
        
        let jsonString = String(content[start...end])
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "AI", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON string"])
        }
        
        let analysisDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        let nutritionArray = analysisDict["nutritionData"] as? [[String: Any]] ?? []
        // Parse nutrition data
        let nutritionData: [NutritionData] = nutritionArray.compactMap { (item: [String: Any]) -> NutritionData? in
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
        
        // Parse recommendations and notes
        let recommendations = analysisDict["recommendations"] as? [String] ?? []
        let professionalNotes = analysisDict["professionalNotes"] as? [String] ?? []
        
        return PDFAnalysisResult(
            extractedText: extractedText,
            nutritionData: nutritionData,
            recommendations: recommendations,
            professionalNotes: professionalNotes
        )
    }
} 
