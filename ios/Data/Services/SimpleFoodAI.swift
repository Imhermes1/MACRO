import Foundation
import Combine

/**
 * SimpleFoodAI - OpenAI GPT-4o-mini integration for intelligent food analysis
 * Provides AI-powered nutrition analysis with Australian food expertise
 * Uses GitHub nutrition database as fallback when AI is unavailable
 */
@MainActor
class SimpleFoodAI: ObservableObject {
    private let openAIAPIKey: String

    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !apiKey.isEmpty else {
            fatalError("OPENAI_API_KEY not found in Info.plist. Please set it up in your configuration.")
        }
        self.openAIAPIKey = apiKey
    }

    // TODO: Re-enable GitHub service once import issues are resolved
    // private let githubService = GitHubNutrientService()
    
    struct OpenAIResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
            
            struct Message: Codable {
                let content: String
            }
        }
    }
    
    struct AIFoodAnalysis: Codable {
        let name: String
        let brand: String?
        let calories: Double
        let protein: Double
        let carbs: Double
        let fat: Double
        let fiber: Double?
        let sugar: Double?
        let sodium: Double?
        let servingSize: String?
        let servingUnit: String?
        let confidence: Double
        let reasoning: String?
    }
    
    /**
     * Main method to analyze food using AI with intelligent fallbacks
     */
    func analyzeFood(_ input: String) async -> NutritionData? {
        // First try AI analysis
        if let aiResult = await performOpenAIAnalysis(input) {
            return aiResult
        }
        
        // TODO: Re-enable GitHub fallback once import issues are resolved
        // Fallback to GitHub database
        // if let githubResult = await githubService.searchFood(input) {
        //     return githubResult
        // }
        
        // Final fallback to basic parsing
        return performBasicAnalysis(input)
    }
    
    /**
     * OpenAI GPT-4o-mini analysis with Australian nutrition expertise
     */
    private func performOpenAIAnalysis(_ input: String) async -> NutritionData? {
        let prompt = """
        You are an Australian nutrition expert specializing in food analysis. Analyze this food description and provide detailed nutrition information in JSON format.

        Food Description: "\(input)"

        Instructions:
        - Use Australian food database knowledge (AUSNUT, NUTTAB)
        - Consider Australian brands, serving sizes, and food standards
        - Be precise with portion estimation from the description
        - Account for cooking methods if mentioned
        - Provide confidence score (0.1-1.0) based on description specificity

        Respond with ONLY valid JSON in this exact format:
        {
          "name": "descriptive food name",
          "brand": "brand name or null",
          "calories": 0.0,
          "protein": 0.0,
          "carbs": 0.0,
          "fat": 0.0,
          "fiber": 0.0,
          "sugar": 0.0,
          "sodium": 0.0,
          "servingSize": "estimated serving size",
          "servingUnit": "g/ml/piece/cup etc",
          "confidence": 0.85,
          "reasoning": "brief explanation of analysis"
        }
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a precise Australian nutrition expert. Always respond with valid JSON only."
                ],
                [
                    "role": "user", 
                    "content": prompt
                ]
            ],
            "max_tokens": 500,
            "temperature": 0.3
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody),
              let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("❌ SimpleFoodAI: Failed to create request")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 OpenAI Response Status: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    if let errorData = String(data: data, encoding: .utf8) {
                        print("❌ OpenAI Error: \(errorData)")
                    }
                    return nil
                }
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let content = openAIResponse.choices.first?.message.content else {
                print("❌ No content in OpenAI response")
                return nil
            }
            
            // Parse the AI's JSON response
            guard let contentData = content.data(using: .utf8) else {
                print("❌ Failed to convert AI response to data")
                return nil
            }
            
            let analysis = try JSONDecoder().decode(AIFoodAnalysis.self, from: contentData)
            
            print("✅ AI Analysis: \(analysis.name) - \(analysis.calories) cal (confidence: \(analysis.confidence))")
            
            return NutritionData(
                name: analysis.name,
                brand: analysis.brand,
                calories: analysis.calories,
                protein: analysis.protein,
                carbs: analysis.carbs,
                fat: analysis.fat,
                fiber: analysis.fiber,
                sugar: analysis.sugar,
                sodium: analysis.sodium,
                confidence: analysis.confidence,
                source: "OpenAI",
                servingSize: analysis.servingSize,
                servingUnit: analysis.servingUnit
            )
            
        } catch {
            print("❌ OpenAI API Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     * Basic analysis fallback using food parsing logic
     */
    private func performBasicAnalysis(_ input: String) -> NutritionData {
        let analysis = analyzeFoodPrompt(input)
        let baseNutrition = getBaseNutrition(for: analysis.foodName)
        let multiplier = getCookingMethodMultiplier(analysis.cookingMethod) * analysis.quantity
        
        return NutritionData(
            name: "\(analysis.quantity) \(analysis.unit) \(analysis.foodName.capitalized)",
            calories: baseNutrition.calories * multiplier,
            protein: baseNutrition.protein * multiplier,
            carbs: baseNutrition.carbs * multiplier,
            fat: baseNutrition.fat * multiplier,
            fiber: baseNutrition.fiber.map { $0 * multiplier },
            sugar: baseNutrition.sugar.map { $0 * multiplier },
            sodium: baseNutrition.sodium.map { $0 * multiplier },
            confidence: analysis.confidence * 0.6, // Lower confidence for basic analysis
            source: "Basic Analysis"
        )
    }
    
    struct FoodPromptAnalysis {
        let foodName: String
        let quantity: Double
        let unit: String
        let cookingMethod: String?
        let confidence: Double
    }
    
    /**
     * Parse and analyze food prompt using simple AI-like logic
     */
    func analyzeFoodPrompt(_ prompt: String) -> FoodPromptAnalysis {
        let lowercased = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extract quantity
        let quantity = extractQuantity(from: lowercased)
        
        // Extract unit
        let unit = extractUnit(from: lowercased)
        
        // Extract cooking method
        let cookingMethod = extractCookingMethod(from: lowercased)
        
        // Extract food name
        let foodName = extractFoodName(from: lowercased)
        
        // Calculate confidence
        let confidence = calculateConfidence(for: lowercased)
        
        return FoodPromptAnalysis(
            foodName: foodName,
            quantity: quantity,
            unit: unit,
            cookingMethod: cookingMethod,
            confidence: confidence
        )
    }
    
    /**
     * Estimate nutrition based on food analysis
     */
    func estimateNutrition(from analysis: FoodPromptAnalysis) -> NutritionData {
        let baseNutrition = getBaseNutrition(for: analysis.foodName)
        
        // Adjust for quantity
        let multiplier = analysis.quantity
        
        // Adjust for cooking method
        let cookingMultiplier = getCookingMethodMultiplier(analysis.cookingMethod)
        
        let finalMultiplier = multiplier * cookingMultiplier
        
        return NutritionData(
            id: UUID(),
            name: "\(analysis.quantity) \(analysis.unit) \(analysis.foodName.capitalized)",
            calories: baseNutrition.calories * finalMultiplier,
            protein: baseNutrition.protein * finalMultiplier,
            carbs: baseNutrition.carbs * finalMultiplier,
            fat: baseNutrition.fat * finalMultiplier,
            fiber: baseNutrition.fiber.map { $0 * finalMultiplier },
            sugar: baseNutrition.sugar.map { $0 * finalMultiplier },
            sodium: baseNutrition.sodium.map { $0 * finalMultiplier },
            confidence: analysis.confidence,
            source: "simple_ai_analysis"
        )
    }
    
    // MARK: - Private extraction methods
    
    private func extractQuantity(from prompt: String) -> Double {
        let quantityPatterns = [
            "one": 1.0, "two": 2.0, "three": 3.0, "four": 4.0, "five": 5.0,
            "half": 0.5, "quarter": 0.25, "double": 2.0,
            "small": 0.7, "medium": 1.0, "large": 1.5, "extra large": 2.0
        ]
        
        for (word, value) in quantityPatterns {
            if prompt.contains(word) {
                return value
            }
        }
        
        // Try to extract numbers
        let regex = try? NSRegularExpression(pattern: "\\b\\d+(\\.\\d+)?\\b")
        if let match = regex?.firstMatch(in: prompt, range: NSRange(prompt.startIndex..., in: prompt)) {
            let numberString = String(prompt[Range(match.range, in: prompt)!])
            return Double(numberString) ?? 1.0
        }
        
        return 1.0 // Default
    }
    
    private func extractUnit(from prompt: String) -> String {
        let units = ["cup", "cups", "bowl", "bowls", "plate", "plates", "serving", "servings", 
                    "piece", "pieces", "slice", "slices", "gram", "grams", "g", "kg", "oz", "lb"]
        
        for unit in units {
            if prompt.contains(unit) {
                return unit
            }
        }
        
        return "serving"
    }
    
    private func extractCookingMethod(from prompt: String) -> String? {
        let methods = ["grilled", "fried", "baked", "boiled", "steamed", "roasted", "raw", "fresh"]
        
        for method in methods {
            if prompt.contains(method) {
                return method
            }
        }
        
        return nil
    }
    
    private func extractFoodName(from prompt: String) -> String {
        var foodName = prompt
        
        // Remove quantities, units, cooking methods
        let wordsToRemove = ["one", "two", "three", "four", "five", "half", "quarter", "double",
                           "small", "medium", "large", "extra", "cup", "cups", "bowl", "bowls",
                           "plate", "plates", "serving", "servings", "piece", "pieces", "slice", "slices",
                           "grilled", "fried", "baked", "boiled", "steamed", "roasted", "fresh", "of", "a", "an"]
        
        for word in wordsToRemove {
            foodName = foodName.replacingOccurrences(of: "\\b\(word)\\b", with: "", options: .regularExpression)
        }
        
        // Remove numbers
        foodName = foodName.replacingOccurrences(of: "\\b\\d+(\\.\\d+)?\\b", with: "", options: .regularExpression)
        
        // Clean up spaces
        foodName = foodName.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return foodName.isEmpty ? "Unknown Food" : foodName
    }
    
    private func calculateConfidence(for prompt: String) -> Double {
        var confidence = 0.5 // Base confidence
        
        // Higher confidence for specific foods
        let knownFoods = ["chicken", "beef", "fish", "rice", "pasta", "apple", "banana", "broccoli"]
        for food in knownFoods {
            if prompt.contains(food) {
                confidence += 0.2
                break
            }
        }
        
        // Higher confidence for cooking methods
        if extractCookingMethod(from: prompt) != nil {
            confidence += 0.1
        }
        
        // Higher confidence for specific quantities
        if prompt.contains(where: { $0.isNumber }) {
            confidence += 0.1
        }
        
        return min(confidence, 1.0)
    }
    
    private func getBaseNutrition(for foodName: String) -> (calories: Double, protein: Double, carbs: Double, fat: Double, fiber: Double?, sugar: Double?, sodium: Double?) {
        let food = foodName.lowercased()
        
        // Protein sources
        if food.contains("chicken") {
            return (165, 31, 0, 3.6, nil, nil, 74)
        } else if food.contains("beef") {
            return (250, 26, 0, 15, nil, nil, 60)
        } else if food.contains("fish") {
            return (140, 25, 0, 4, nil, nil, 50)
        }
        // Fruits
        else if food.contains("apple") {
            return (52, 0.3, 14, 0.2, 2.4, 10, 1)
        } else if food.contains("banana") {
            return (89, 1.1, 23, 0.3, 2.6, 12, 1)
        }
        // Vegetables
        else if food.contains("broccoli") {
            return (25, 2.6, 5, 0.4, 3, 1.5, 41)
        } else if food.contains("carrot") {
            return (41, 0.9, 10, 0.2, 2.8, 4.7, 69)
        }
        // Grains
        else if food.contains("rice") {
            return (130, 2.7, 28, 0.3, 0.4, 0.1, 1)
        } else if food.contains("pasta") {
            return (131, 5, 25, 1.1, 1.8, 0.6, 1)
        }
        // Default
        else {
            return (100, 3, 15, 3, 2, 5, 50)
        }
    }
    
    private func getCookingMethodMultiplier(_ method: String?) -> Double {
        guard let method = method else { return 1.0 }
        
        switch method.lowercased() {
        case "fried":
            return 1.3 // More calories from oil
        case "baked", "roasted":
            return 1.1 // Slight increase
        case "grilled", "steamed", "boiled":
            return 0.95 // Slight decrease
        case "raw", "fresh":
            return 1.0
        default:
            return 1.0
        }
    }
}