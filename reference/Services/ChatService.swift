//
//  ChatService.swift
//  CoreTrack
//
//  Created by Luke Fornieri on 11/6/2025.
//

import Foundation

// MARK: - Chat Service
class ChatService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        // Try multiple methods to retrieve API key with better error handling
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "AI_API_KEY") as? String, !apiKey.isEmpty {
            self.apiKey = apiKey
            print("✅ ChatService: API key loaded successfully")
        } else if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path),
                  let apiKey = plist["AI_API_KEY"] as? String, !apiKey.isEmpty {
            self.apiKey = apiKey
            print("✅ ChatService: API key loaded from Info.plist")
        } else {
            print("⚠️ Warning: AI_API_KEY not found in Info.plist or bundle")
            self.apiKey = ""
        }
    }
    
    func sendMessage(_ message: String, context: ChatContext) async throws -> String {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "AI API key not found"])
        }
        
        let prompt = createChatPrompt(message: message, context: context)
        let requestBody = createChatRequestBody(prompt: prompt)
        
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
        
        return try parseChatResponse(data: data)
    }
    
    func generateMealPlan(preferences: MealPreferences) async throws -> MealPlan {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "AI API key not found"])
        }
        
        let prompt = createMealPlanPrompt(preferences: preferences)
        let requestBody = createChatRequestBody(prompt: prompt)
        
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
        
        return try parseMealPlanResponse(data: data)
    }
    
    private func createChatPrompt(message: String, context: ChatContext) -> String {
        return """
        You are an expert Australian nutritionist and personal coach. The user is asking: "\(message)"
        
        USER PROFILE:
        - Age: \(context.userProfile.age)
        - Weight: \(context.userProfile.weight)kg
        - Height: \(context.userProfile.height)cm
        - Activity Level: \(context.userProfile.activityLevel.rawValue)
        - Dietary Restrictions: \(context.userProfile.dietaryRestrictions.map { $0.rawValue }.joined(separator: ", "))
        - Health Conditions: \(context.userProfile.healthConditions.map { $0.rawValue }.joined(separator: ", "))
        
        CURRENT GOALS:
        - Calorie Goal: \(context.currentGoals.calorieGoal) calories
        - Protein Goal: \(context.currentGoals.proteinGoal)g
        - Carb Goal: \(context.currentGoals.carbGoal)g
        - Fat Goal: \(context.currentGoals.fatGoal)g
        - Weight Goal: \(context.currentGoals.weightGoal.rawValue)
        
        Provide helpful, personalised advice in a friendly, encouraging tone. Be specific and actionable. Use Australian food standards and brands when relevant.
        """
    }
    
    private func createMealPlanPrompt(preferences: MealPreferences) -> String {
        return """
        Create a personalised meal plan with the following preferences:
        - Cuisine: \(preferences.cuisine.map { $0.rawValue }.joined(separator: ", "))
        - Cooking Time: \(preferences.cookingTime.rawValue)
        - Servings: \(preferences.servings)
        - Budget: \(preferences.budget.rawValue)
        
        Return a JSON object with:
        {
          "meals": [
            {
              "name": "Meal Name",
              "ingredients": [
                {"name": "Ingredient", "amount": 100, "unit": "g"}
              ],
              "instructions": ["Step 1", "Step 2"],
              "nutrition": {
                "calories": 500,
                "protein": 25,
                "carbs": 45,
                "fat": 20
              },
              "prepTime": 10,
              "cookTime": 20,
              "difficulty": "Easy"
            }
          ],
          "totalCalories": 2000,
          "totalProtein": 100,
          "totalCarbs": 180,
          "totalFat": 80,
          "shoppingList": [
            {"name": "Item", "amount": 200, "unit": "g", "category": "Produce"}
          ]
        }
        """
    }
    
    private func createChatRequestBody(prompt: String) -> [String: Any] {
        return [
            "model": "gpt-4.1-mini-2025-04-14",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 800,
            "temperature": 0.7
        ]
    }
    
    private func parseChatResponse(data: Data) throws -> String {
        let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = response?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "AI", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
        }
        
        return content
    }
    
    private func parseMealPlanResponse(data: Data) throws -> MealPlan {
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
        
        let mealPlanDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
        
        // Parse meals
        let mealsArray = mealPlanDict["meals"] as? [[String: Any]] ?? []
        let meals = mealsArray.compactMap { mealDict -> Meal? in
            guard let name = mealDict["name"] as? String,
                  let ingredientsArray = mealDict["ingredients"] as? [[String: Any]],
                  let instructions = mealDict["instructions"] as? [String],
                  let nutritionDict = mealDict["nutrition"] as? [String: Any],
                  let prepTime = mealDict["prepTime"] as? Int,
                  let cookTime = mealDict["cookTime"] as? Int,
                  let difficultyString = mealDict["difficulty"] as? String,
                  let difficulty = Difficulty(rawValue: difficultyString) else {
                return nil
            }
            
            let ingredients = ingredientsArray.compactMap { ingredientDict -> Ingredient? in
                guard let name = ingredientDict["name"] as? String,
                      let amount = ingredientDict["amount"] as? Double,
                      let unit = ingredientDict["unit"] as? String else {
                    return nil
                }
                return Ingredient(name: name, amount: amount, unit: unit)
            }
            
            let nutrition = NutritionData(
                calories: nutritionDict["calories"] as? Double ?? 0,
                protein: nutritionDict["protein"] as? Double ?? 0,
                carbs: nutritionDict["carbs"] as? Double ?? 0,
                fat: nutritionDict["fat"] as? Double ?? 0,
                description: name
            )
            
            return Meal(
                name: name,
                ingredients: ingredients,
                instructions: instructions,
                nutrition: nutrition,
                prepTime: prepTime,
                cookTime: cookTime,
                difficulty: difficulty
            )
        }
        
        // Parse shopping list
        let shoppingArray = mealPlanDict["shoppingList"] as? [[String: Any]] ?? []
        let shoppingList = shoppingArray.compactMap { itemDict -> ShoppingItem? in
            guard let name = itemDict["name"] as? String,
                  let amount = itemDict["amount"] as? Double,
                  let unit = itemDict["unit"] as? String,
                  let categoryString = itemDict["category"] as? String,
                  let category = ShoppingCategory(rawValue: categoryString) else {
                return nil
            }
            return ShoppingItem(name: name, amount: amount, unit: unit, category: category)
        }
        
        return MealPlan(
            meals: meals,
            totalCalories: mealPlanDict["totalCalories"] as? Double ?? 0,
            totalProtein: mealPlanDict["totalProtein"] as? Double ?? 0,
            totalCarbs: mealPlanDict["totalCarbs"] as? Double ?? 0,
            totalFat: mealPlanDict["totalFat"] as? Double ?? 0,
            shoppingList: shoppingList
        )
    }
} 