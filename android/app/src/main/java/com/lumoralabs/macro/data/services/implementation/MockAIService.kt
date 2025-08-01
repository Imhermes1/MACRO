package com.lumoralabs.macro.data.services.implementation

import android.content.Context
import android.util.Log
import com.lumoralabs.macro.data.models.*
import com.lumoralabs.macro.data.services.AIServiceProtocol
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/**
 * Mock AI Service Implementation for Android Development
 * 
 * Provides realistic mock responses for AI analysis without requiring API keys
 * Perfect for development, testing, and when API services are unavailable
 */
class MockAIService(
    private val context: Context
) : AIServiceProtocol {
    
    companion object {
        private const val TAG = "MockAIService"
    }
    
    // MARK: - State Management
    
    private val _isProcessing = MutableStateFlow(false)
    override val isProcessing: Flow<Boolean> = _isProcessing.asStateFlow()
    
    private val _lastError = MutableStateFlow<Throwable?>(null)
    override val lastError: Flow<Throwable?> = _lastError.asStateFlow()
    
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }
    
    init {
        Log.d(TAG, "MockAIService initialized for development")
    }
    
    // MARK: - AIServiceProtocol Implementation
    
    override suspend fun analyzeText(text: String, context: AnalysisContext): Result<AIAnalysisResult> {
        Log.d(TAG, "Mock analyzing text: ${text.take(50)}...")
        
        _isProcessing.value = true
        _lastError.value = null
        
        return try {
            // Simulate realistic processing time
            delay(when (context) {
                AnalysisContext.TEXT -> 500L
                AnalysisContext.RECIPE -> 1000L
                AnalysisContext.BARCODE -> 300L
                AnalysisContext.IMAGE -> 800L
            })
            
            val nutritionData = generateMockNutritionFromText(text, context)
            val nutritionJson = json.encodeToString(nutritionData)
            
            val result = AIAnalysisResult(
                content = nutritionJson,
                confidence = generateRealisticConfidence(text, context),
                metadata = mapOf(
                    "provider" to "mock",
                    "model" to "mock_analyzer_v1",
                    "context" to context.name,
                    "processing_time_ms" to "500"
                )
            )
            
            Result.success(result)
            
        } catch (e: Exception) {
            Log.e(TAG, "Mock text analysis failed", e)
            _lastError.value = e
            Result.failure(e)
        } finally {
            _isProcessing.value = false
        }
    }
    
    override suspend fun analyzeImage(imageData: ByteArray, prompt: String): Result<AIAnalysisResult> {
        Log.d(TAG, "Mock analyzing image (${imageData.size} bytes)")
        
        _isProcessing.value = true
        _lastError.value = null
        
        return try {
            // Simulate longer processing for image analysis
            delay(1200L)
            
            val nutritionData = generateMockNutritionFromImage(imageData, prompt)
            val nutritionJson = json.encodeToString(nutritionData)
            
            val result = AIAnalysisResult(
                content = nutritionJson,
                confidence = 0.65, // Lower confidence for mock image analysis
                metadata = mapOf(
                    "provider" to "mock",
                    "model" to "mock_vision_v1",
                    "image_size_bytes" to imageData.size.toString(),
                    "processing_time_ms" to "1200"
                )
            )
            
            Result.success(result)
            
        } catch (e: Exception) {
            Log.e(TAG, "Mock image analysis failed", e)
            _lastError.value = e
            Result.failure(e)
        } finally {
            _isProcessing.value = false
        }
    }
    
    override suspend fun generateResponse(prompt: String, context: AnalysisContext): Result<String> {
        Log.d(TAG, "Mock generating response for: ${prompt.take(30)}...")
        
        _isProcessing.value = true
        _lastError.value = null
        
        return try {
            delay(400L)
            
            val response = generateMockConversationalResponse(prompt, context)
            Result.success(response)
            
        } catch (e: Exception) {
            Log.e(TAG, "Mock response generation failed", e)
            _lastError.value = e
            Result.failure(e)
        } finally {
            _isProcessing.value = false
        }
    }
    
    // MARK: - Mock Data Generation
    
    private fun generateMockNutritionFromText(text: String, context: AnalysisContext): NutritionData {
        val words = text.lowercase().split("\\s+".toRegex())
        
        // Base nutrition values
        var calories = 100.0
        var protein = 5.0
        var carbs = 15.0
        var fat = 3.0
        var fiber = 2.0
        var sugar = 3.0
        var sodium = 50.0
        
        // Analyze text for food keywords and adjust nutrition
        for (word in words) {
            when {
                // Proteins
                word.contains("chicken") -> { protein += 25.0; calories += 165.0; fat += 3.6 }
                word.contains("beef") -> { protein += 26.0; calories += 250.0; fat += 15.0 }
                word.contains("fish") || word.contains("salmon") -> { protein += 22.0; calories += 206.0; fat += 12.0 }
                word.contains("egg") -> { protein += 6.0; calories += 70.0; fat += 5.0 }
                word.contains("tofu") -> { protein += 8.0; calories += 70.0; fat += 4.0 }
                
                // Carbohydrates
                word.contains("rice") -> { carbs += 28.0; calories += 130.0; protein += 2.7 }
                word.contains("bread") -> { carbs += 14.0; calories += 80.0; protein += 4.0; fiber += 2.0 }
                word.contains("pasta") -> { carbs += 31.0; calories += 131.0; protein += 5.0 }
                word.contains("potato") -> { carbs += 26.0; calories += 110.0; protein += 3.0; fiber += 2.6 }
                word.contains("oats") -> { carbs += 27.0; calories += 150.0; protein += 5.0; fiber += 4.0 }
                
                // Fats
                word.contains("oil") || word.contains("olive") -> { fat += 14.0; calories += 120.0 }
                word.contains("butter") -> { fat += 11.0; calories += 102.0; sodium += 90.0 }
                word.contains("nuts") || word.contains("almond") -> { fat += 14.0; calories += 160.0; protein += 6.0; fiber += 3.5 }
                word.contains("avocado") -> { fat += 15.0; calories += 160.0; fiber += 7.0 }
                
                // Vegetables
                word.contains("broccoli") -> { carbs += 6.0; calories += 25.0; protein += 3.0; fiber += 2.6 }
                word.contains("spinach") -> { carbs += 1.0; calories += 7.0; protein += 0.9; fiber += 0.7 }
                word.contains("tomato") -> { carbs += 4.0; calories += 18.0; sugar += 2.6; fiber += 1.2 }
                
                // Fruits
                word.contains("apple") -> { carbs += 14.0; calories += 52.0; sugar += 10.0; fiber += 2.4 }
                word.contains("banana") -> { carbs += 23.0; calories += 89.0; sugar += 12.0; fiber += 2.6 }
                word.contains("orange") -> { carbs += 12.0; calories += 47.0; sugar += 9.0; fiber += 2.4 }
                
                // Dairy
                word.contains("milk") -> { carbs += 5.0; calories += 42.0; protein += 3.4; fat += 1.0; sugar += 5.0 }
                word.contains("cheese") -> { calories += 113.0; protein += 7.0; fat += 9.0; sodium += 180.0 }
                word.contains("yogurt") -> { carbs += 6.0; calories += 59.0; protein += 10.0; sugar += 5.0 }
            }
        }
        
        // Context-specific adjustments
        when (context) {
            AnalysisContext.RECIPE -> {
                // Recipes typically have multiple ingredients
                calories *= 1.2
                protein *= 1.1
                carbs *= 1.15
                fat *= 1.1
            }
            AnalysisContext.BARCODE -> {
                // Barcode items are typically processed foods
                sodium *= 1.5
                sugar *= 1.3
            }
            else -> { /* no adjustment */ }
        }
        
        return NutritionData(
            name = extractFoodName(text),
            brand = extractBrand(words),
            calories = calories.coerceAtLeast(0.0),
            protein = protein.coerceAtLeast(0.0),
            carbs = carbs.coerceAtLeast(0.0),
            fat = fat.coerceAtLeast(0.0),
            fiber = fiber.coerceAtLeast(0.0),
            sugar = sugar.coerceAtLeast(0.0),
            sodium = sodium.coerceAtLeast(0.0),
            confidence = generateRealisticConfidence(text, context),
            source = "mock_analysis",
            servingSize = generateServingSize(words),
            servingUnit = generateServingUnit(words)
        )
    }
    
    private fun generateMockNutritionFromImage(imageData: ByteArray, prompt: String): NutritionData {
        // Simulate image analysis by using prompt text and image size as factors
        val imageSizeFactor = (imageData.size / 100000.0).coerceIn(0.5, 2.0)
        
        return NutritionData(
            name = extractFoodNameFromPrompt(prompt),
            calories = (150.0 * imageSizeFactor),
            protein = (8.0 * imageSizeFactor),
            carbs = (20.0 * imageSizeFactor),
            fat = (6.0 * imageSizeFactor),
            fiber = 3.0,
            sugar = 5.0,
            sodium = 120.0,
            confidence = 0.65, // Lower confidence for image analysis
            source = "mock_image_analysis",
            servingSize = "1 serving",
            servingUnit = "serving"
        )
    }
    
    private fun generateMockConversationalResponse(prompt: String, context: AnalysisContext): String {
        val responses = when {
            prompt.lowercase().contains("calorie") -> listOf(
                "Based on typical nutritional values, this food item contains approximately 150-200 calories per serving.",
                "The calorie content depends on preparation method and serving size. I'd estimate around 180 calories.",
                "For accurate calorie information, I'd recommend checking the nutrition label or using precise measurements."
            )
            
            prompt.lowercase().contains("protein") -> listOf(
                "This appears to be a good source of protein, providing approximately 8-12 grams per serving.",
                "The protein content looks substantial - likely around 10 grams based on the ingredients.",
                "For optimal protein intake, consider pairing this with other protein-rich foods."
            )
            
            prompt.lowercase().contains("healthy") -> listOf(
                "This food provides a good balance of macronutrients and appears to be a healthy choice.",
                "Based on the nutritional profile, this fits well into a balanced diet.",
                "Consider the overall nutritional context of your daily intake when evaluating healthiness."
            )
            
            else -> listOf(
                "I can help analyze the nutritional content of your food. Would you like me to break down the macronutrients?",
                "This food item has a balanced nutritional profile. Is there a specific nutrient you're interested in?",
                "Based on my analysis, this appears to be a nutritious food choice with good macro balance."
            )
        }
        
        return responses.random()
    }
    
    // MARK: - Helper Functions
    
    private fun generateRealisticConfidence(text: String, context: AnalysisContext): Double {
        val baseConfidence = when (context) {
            AnalysisContext.TEXT -> 0.85
            AnalysisContext.BARCODE -> 0.95
            AnalysisContext.RECIPE -> 0.80
            AnalysisContext.IMAGE -> 0.70
        }
        
        // Adjust based on text specificity
        val specificityBonus = when {
            text.length > 50 -> 0.05
            text.contains("gram") || text.contains("cup") || text.contains("oz") -> 0.10
            text.split(" ").size > 5 -> 0.05
            else -> 0.0
        }
        
        return (baseConfidence + specificityBonus).coerceIn(0.6, 0.95)
    }
    
    private fun extractFoodName(text: String): String {
        val cleaned = text.trim().take(50)
        return if (cleaned.isNotBlank()) cleaned else "Unknown Food"
    }
    
    private fun extractFoodNameFromPrompt(prompt: String): String {
        return if (prompt.isNotBlank()) {
            "Food from image: ${prompt.take(30)}"
        } else {
            "Food from image"
        }
    }
    
    private fun extractBrand(words: List<String>): String? {
        val brandKeywords = listOf("brand", "organic", "fresh", "natural", "premium")
        return words.find { word -> 
            brandKeywords.any { keyword -> word.contains(keyword, ignoreCase = true) }
        }?.replaceFirstChar { it.uppercaseChar() }
    }
    
    private fun generateServingSize(words: List<String>): String {
        return when {
            words.any { it.contains("cup") } -> "1 cup"
            words.any { it.contains("piece") || it.contains("slice") } -> "1 piece"
            words.any { it.contains("gram") } -> "100g"
            words.any { it.contains("oz") } -> "1 oz"
            else -> "1 serving"
        }
    }
    
    private fun generateServingUnit(words: List<String>): String {
        return when {
            words.any { it.contains("cup") } -> "cup"
            words.any { it.contains("piece") } -> "piece"
            words.any { it.contains("slice") } -> "slice"
            words.any { it.contains("gram") } -> "gram"
            words.any { it.contains("oz") } -> "ounce"
            else -> "serving"
        }
    }
}
