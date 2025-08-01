package com.lumoralabs.macro.data.services.implementation

import android.content.Context
import android.util.Log
import com.lumoralabs.macro.data.configuration.AppConfiguration
import com.lumoralabs.macro.data.configuration.ConfigurationHelper
import com.lumoralabs.macro.data.models.*
import com.lumoralabs.macro.data.services.AIServiceProtocol
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.util.concurrent.TimeUnit
import android.util.Base64

/**
 * Production AI Service Implementation for Android
 * 
 * Integrates with real AI APIs (OpenAI, Anthropic) for nutrition analysis
 * using modern Android architecture patterns with Kotlin coroutines
 */
class ProductionAIService(
    private val context: Context,
    private val configuration: AppConfiguration = AppConfiguration.getInstance(context)
) : AIServiceProtocol {
    
    companion object {
        private const val TAG = "ProductionAIService"
        private const val JSON_MEDIA_TYPE = "application/json; charset=utf-8"
    }
    
    // MARK: - State Management
    
    private val _isProcessing = MutableStateFlow(false)
    override val isProcessing: Flow<Boolean> = _isProcessing.asStateFlow()
    
    private val _lastError = MutableStateFlow<Throwable?>(null)
    override val lastError: Flow<Throwable?> = _lastError.asStateFlow()
    
    // MARK: - HTTP Client Configuration
    
    private val httpClient: OkHttpClient by lazy {
        OkHttpClient.Builder()
            .connectTimeout(ConfigurationHelper.Defaults.REQUEST_TIMEOUT_MS, TimeUnit.MILLISECONDS)
            .readTimeout(ConfigurationHelper.Defaults.REQUEST_TIMEOUT_MS, TimeUnit.MILLISECONDS)
            .writeTimeout(ConfigurationHelper.Defaults.REQUEST_TIMEOUT_MS, TimeUnit.MILLISECONDS)
            .addInterceptor { chain ->
                val request = chain.request()
                Log.d(TAG, "Making API request to: ${request.url}")
                chain.proceed(request)
            }
            .build()
    }
    
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }
    
    // MARK: - Service Selection
    
    private enum class AIProvider {
        OPENAI, ANTHROPIC, FALLBACK
    }
    
    private val preferredProvider: AIProvider
        get() = when {
            configuration.openAIAPIKey.isNotEmpty() -> AIProvider.OPENAI
            configuration.anthropicAPIKey.isNotEmpty() -> AIProvider.ANTHROPIC
            else -> AIProvider.FALLBACK
        }
    
    init {
        Log.d(TAG, "ProductionAIService initialized with provider: $preferredProvider")
        if (configuration.enableLogging) {
            configuration.printConfigurationStatus()
        }
    }
    
    // MARK: - AIServiceProtocol Implementation
    
    override suspend fun analyzeText(text: String, context: AnalysisContext): Result<AIAnalysisResult> {
        Log.d(TAG, "Analyzing text with provider: $preferredProvider")
        
        _isProcessing.value = true
        _lastError.value = null
        
        return try {
            val result = when (preferredProvider) {
                AIProvider.OPENAI -> analyzeWithOpenAI(text, context)
                AIProvider.ANTHROPIC -> analyzeWithAnthropic(text, context)
                AIProvider.FALLBACK -> analyzeWithFallback(text, context)
            }
            
            Result.success(result)
        } catch (e: Exception) {
            Log.e(TAG, "Text analysis failed", e)
            _lastError.value = e
            
            // Try fallback if primary service fails
            if (preferredProvider != AIProvider.FALLBACK) {
                try {
                    Log.d(TAG, "Attempting fallback analysis")
                    val fallbackResult = analyzeWithFallback(text, context)
                    Result.success(fallbackResult)
                } catch (fallbackException: Exception) {
                    Result.failure(e)
                }
            } else {
                Result.failure(e)
            }
        } finally {
            _isProcessing.value = false
        }
    }
    
    override suspend fun analyzeImage(imageData: ByteArray, prompt: String): Result<AIAnalysisResult> {
        Log.d(TAG, "Analyzing image with provider: $preferredProvider")
        
        _isProcessing.value = true
        _lastError.value = null
        
        return try {
            val result = when (preferredProvider) {
                AIProvider.OPENAI -> analyzeImageWithOpenAI(imageData, prompt)
                AIProvider.ANTHROPIC -> analyzeImageWithAnthropic(imageData, prompt)
                AIProvider.FALLBACK -> analyzeImageWithFallback(imageData, prompt)
            }
            
            Result.success(result)
        } catch (e: Exception) {
            Log.e(TAG, "Image analysis failed", e)
            _lastError.value = e
            
            // Try fallback if primary service fails
            if (preferredProvider != AIProvider.FALLBACK) {
                try {
                    Log.d(TAG, "Attempting fallback image analysis")
                    val fallbackResult = analyzeImageWithFallback(imageData, prompt)
                    Result.success(fallbackResult)
                } catch (fallbackException: Exception) {
                    Result.failure(e)
                }
            } else {
                Result.failure(e)
            }
        } finally {
            _isProcessing.value = false
        }
    }
    
    override suspend fun generateResponse(prompt: String, context: AnalysisContext): Result<String> {
        Log.d(TAG, "Generating response with provider: $preferredProvider")
        
        _isProcessing.value = true
        
        return try {
            val result = when (preferredProvider) {
                AIProvider.OPENAI -> generateResponseWithOpenAI(prompt, context)
                AIProvider.ANTHROPIC -> generateResponseWithAnthropic(prompt, context)
                AIProvider.FALLBACK -> generateResponseWithFallback(prompt, context)
            }
            
            Result.success(result)
        } catch (e: Exception) {
            Log.e(TAG, "Response generation failed", e)
            _lastError.value = e
            Result.failure(e)
        } finally {
            _isProcessing.value = false
        }
    }
    
    // MARK: - OpenAI Implementation
    
    private suspend fun analyzeWithOpenAI(text: String, context: AnalysisContext): AIAnalysisResult {
        val systemPrompt = createNutritionSystemPrompt(context)
        val userPrompt = createNutritionUserPrompt(text)
        
        val requestBody = mapOf(
            "model" to "gpt-4o-mini",
            "messages" to listOf(
                mapOf("role" to "system", "content" to systemPrompt),
                mapOf("role" to "user", "content" to userPrompt)
            ),
            "temperature" to 0.1,
            "max_tokens" to 1000
        )
        
        val response = makeOpenAIRequest("/chat/completions", requestBody)
        return parseOpenAIResponse(response)
    }
    
    private suspend fun analyzeImageWithOpenAI(imageData: ByteArray, prompt: String): AIAnalysisResult {
        val base64Image = Base64.encodeToString(imageData, Base64.NO_WRAP)
        val systemPrompt = createNutritionSystemPrompt(AnalysisContext.IMAGE)
        
        val requestBody = mapOf(
            "model" to "gpt-4-vision-preview",
            "messages" to listOf(
                mapOf("role" to "system", "content" to systemPrompt),
                mapOf(
                    "role" to "user",
                    "content" to listOf(
                        mapOf("type" to "text", "text" to prompt),
                        mapOf(
                            "type" to "image_url",
                            "image_url" to mapOf(
                                "url" to "data:image/jpeg;base64,$base64Image"
                            )
                        )
                    )
                )
            ),
            "max_tokens" to 1000
        )
        
        val response = makeOpenAIRequest("/chat/completions", requestBody)
        return parseOpenAIResponse(response)
    }
    
    private suspend fun generateResponseWithOpenAI(prompt: String, context: AnalysisContext): String {
        val systemPrompt = "You are a helpful nutrition assistant. Provide accurate, concise responses about food and nutrition."
        
        val requestBody = mapOf(
            "model" to "gpt-3.5-turbo",
            "messages" to listOf(
                mapOf("role" to "system", "content" to systemPrompt),
                mapOf("role" to "user", "content" to prompt)
            ),
            "temperature" to 0.7,
            "max_tokens" to 500
        )
        
        val response = makeOpenAIRequest("/chat/completions", requestBody)
        
        @Suppress("UNCHECKED_CAST")
        val choices = response["choices"] as? List<Map<String, Any>>
        val firstChoice = choices?.firstOrNull() as? Map<String, Any>
        val message = firstChoice?.get("message") as? Map<String, Any>
        val content = message?.get("content") as? String
        
        return content ?: throw AIServiceException("Invalid OpenAI response format")
    }
    
    private suspend fun makeOpenAIRequest(endpoint: String, body: Map<String, Any>): Map<String, Any> {
        val url = ConfigurationHelper.Endpoints.OPENAI_BASE_URL + endpoint
        val jsonBody = json.encodeToString(body)
        
        val request = Request.Builder()
            .url(url)
            .post(jsonBody.toRequestBody(JSON_MEDIA_TYPE.toMediaType()))
            .addHeader("Authorization", "Bearer ${configuration.openAIAPIKey}")
            .addHeader("Content-Type", "application/json")
            .build()
        
        return executeRequest(request)
    }
    
    // MARK: - Anthropic Implementation
    
    private suspend fun analyzeWithAnthropic(text: String, context: AnalysisContext): AIAnalysisResult {
        val systemPrompt = createNutritionSystemPrompt(context)
        val userPrompt = createNutritionUserPrompt(text)
        
        val requestBody = mapOf(
            "model" to "claude-3-sonnet-20240229",
            "max_tokens" to 1000,
            "temperature" to 0.1,
            "system" to systemPrompt,
            "messages" to listOf(
                mapOf("role" to "user", "content" to userPrompt)
            )
        )
        
        val response = makeAnthropicRequest("/messages", requestBody)
        return parseAnthropicResponse(response)
    }
    
    private suspend fun analyzeImageWithAnthropic(imageData: ByteArray, prompt: String): AIAnalysisResult {
        // Anthropic doesn't support vision analysis yet, use fallback
        throw AIServiceException("Vision analysis not supported by Anthropic Claude")
    }
    
    private suspend fun generateResponseWithAnthropic(prompt: String, context: AnalysisContext): String {
        val systemPrompt = "You are a helpful nutrition assistant. Provide accurate, concise responses about food and nutrition."
        
        val requestBody = mapOf(
            "model" to "claude-3-haiku-20240307",
            "max_tokens" to 500,
            "temperature" to 0.7,
            "system" to systemPrompt,
            "messages" to listOf(
                mapOf("role" to "user", "content" to prompt)
            )
        )
        
        val response = makeAnthropicRequest("/messages", requestBody)
        
        @Suppress("UNCHECKED_CAST")
        val content = response["content"] as? List<Map<String, Any>>
        val firstContent = content?.firstOrNull() as? Map<String, Any>
        val text = firstContent?.get("text") as? String
        
        return text ?: throw AIServiceException("Invalid Anthropic response format")
    }
    
    private suspend fun makeAnthropicRequest(endpoint: String, body: Map<String, Any>): Map<String, Any> {
        val url = ConfigurationHelper.Endpoints.ANTHROPIC_BASE_URL + endpoint
        val jsonBody = json.encodeToString(body)
        
        val request = Request.Builder()
            .url(url)
            .post(jsonBody.toRequestBody(JSON_MEDIA_TYPE.toMediaType()))
            .addHeader("x-api-key", configuration.anthropicAPIKey)
            .addHeader("anthropic-version", "2023-06-01")
            .addHeader("Content-Type", "application/json")
            .build()
        
        return executeRequest(request)
    }
    
    // MARK: - Fallback Implementation
    
    private suspend fun analyzeWithFallback(text: String, context: AnalysisContext): AIAnalysisResult {
        Log.d(TAG, "Using fallback AI analysis for text")
        
        // Simulate processing delay
        kotlinx.coroutines.delay(500)
        
        val nutritionData = generateMockNutritionData(text)
        val nutritionJson = json.encodeToString(nutritionData)
        
        return AIAnalysisResult(
            content = nutritionJson,
            confidence = 0.6,
            metadata = mapOf(
                "provider" to "fallback",
                "model" to "mock_analyzer"
            )
        )
    }
    
    private suspend fun analyzeImageWithFallback(imageData: ByteArray, prompt: String): AIAnalysisResult {
        Log.d(TAG, "Using fallback AI analysis for image")
        
        kotlinx.coroutines.delay(1000)
        
        val nutritionData = NutritionData(
            name = "Food from image",
            calories = 150.0,
            protein = 8.0,
            carbs = 25.0,
            fat = 5.0,
            fiber = 3.0,
            sugar = 8.0,
            sodium = 200.0,
            confidence = 0.5,
            source = "image_analysis"
        )
        
        val nutritionJson = json.encodeToString(nutritionData)
        
        return AIAnalysisResult(
            content = nutritionJson,
            confidence = 0.5,
            metadata = mapOf(
                "provider" to "fallback",
                "model" to "mock_vision"
            )
        )
    }
    
    private suspend fun generateResponseWithFallback(prompt: String, context: AnalysisContext): String {
        kotlinx.coroutines.delay(300)
        return "Mock AI response for: $prompt"
    }
    
    // MARK: - HTTP Utilities
    
    private suspend fun executeRequest(request: Request): Map<String, Any> {
        return kotlinx.coroutines.suspendCancellableCoroutine { continuation ->
            httpClient.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    continuation.resumeWith(Result.failure(AIServiceException("Network error: ${e.message}", e)))
                }
                
                override fun onResponse(call: Call, response: Response) {
                    try {
                        val responseBody = response.body?.string() ?: ""
                        
                        if (!response.isSuccessful) {
                            continuation.resumeWith(
                                Result.failure(
                                    AIServiceException("API error: ${response.code} - $responseBody")
                                )
                            )
                            return
                        }
                        
                        @Suppress("UNCHECKED_CAST")
                        val jsonResponse = json.decodeFromString<Map<String, Any>>(responseBody) 
                        continuation.resumeWith(Result.success(jsonResponse))
                        
                    } catch (e: Exception) {
                        continuation.resumeWith(Result.failure(AIServiceException("Response parsing error", e)))
                    }
                }
            })
        }
    }
    
    // MARK: - Response Parsing
    
    private fun parseOpenAIResponse(response: Map<String, Any>): AIAnalysisResult {
        @Suppress("UNCHECKED_CAST")
        val choices = response["choices"] as? List<Map<String, Any>>
        val firstChoice = choices?.firstOrNull() as? Map<String, Any>
        val message = firstChoice?.get("message") as? Map<String, Any>
        val content = message?.get("content") as? String
        
        return AIAnalysisResult(
            content = content ?: throw AIServiceException("Invalid OpenAI response format"),
            confidence = 0.9,
            metadata = mapOf(
                "provider" to "openai",
                "model" to "gpt-4"
            )
        )
    }
    
    private fun parseAnthropicResponse(response: Map<String, Any>): AIAnalysisResult {
        @Suppress("UNCHECKED_CAST")
        val content = response["content"] as? List<Map<String, Any>>
        val firstContent = content?.firstOrNull() as? Map<String, Any>
        val text = firstContent?.get("text") as? String
        
        return AIAnalysisResult(
            content = text ?: throw AIServiceException("Invalid Anthropic response format"),
            confidence = 0.9,
            metadata = mapOf(
                "provider" to "anthropic",
                "model" to "claude-3"
            )
        )
    }
    
    // MARK: - Prompt Engineering
    
    private fun createNutritionSystemPrompt(context: AnalysisContext): String {
        val basePrompt = """
        You are a professional nutritionist AI assistant. Your task is to analyze food descriptions and provide accurate nutritional information.
        
        IMPORTANT: Respond ONLY with valid JSON in the exact format specified below. Do not include any other text, explanations, or markdown formatting.
        
        Required JSON format:
        {
            "id": "generated_uuid",
            "name": "Food name",
            "brand": "Brand name (if applicable)",
            "calories": number,
            "protein": number,
            "carbs": number,
            "fat": number,
            "fiber": number,
            "sugar": number,
            "sodium": number,
            "confidence": number (0.0-1.0),
            "source": "ai_analysis",
            "servingSize": "serving size description",
            "servingUnit": "unit (e.g., cup, piece, gram)"
        }
        
        Guidelines:
        - Provide nutritional values per serving
        - Use grams for protein, carbs, fat, fiber, sugar, sodium
        - Use whole numbers for calories
        - Confidence should reflect your certainty (0.7-0.95 typical)
        - If brand is unknown, use null
        - Be conservative with estimates - better to underestimate than overestimate
        """.trimIndent()
        
        return when (context) {
            AnalysisContext.TEXT -> "$basePrompt\n\nYou will analyze text descriptions of food items."
            AnalysisContext.IMAGE -> "$basePrompt\n\nYou will analyze images of food items. Estimate portions based on visual cues."
            AnalysisContext.BARCODE -> "$basePrompt\n\nYou will analyze food items identified by barcode lookup."
            AnalysisContext.RECIPE -> "$basePrompt\n\nYou will analyze recipe descriptions. Calculate per-serving values."
        }
    }
    
    private fun createNutritionUserPrompt(text: String): String {
        return "Analyze this food description and provide nutritional information: $text"
    }
    
    // MARK: - Mock Data Generation
    
    private fun generateMockNutritionData(text: String): NutritionData {
        val words = text.lowercase().split("\\s+".toRegex())
        
        var calories = 100.0
        var protein = 5.0
        var carbs = 15.0
        var fat = 3.0
        
        for (word in words) {
            when (word) {
                "chicken", "beef", "fish" -> {
                    protein += 20.0
                    calories += 150.0
                }
                "rice", "bread", "pasta" -> {
                    carbs += 25.0
                    calories += 100.0
                }
                "oil", "butter", "nuts" -> {
                    fat += 15.0
                    calories += 135.0
                }
            }
        }
        
        return NutritionData(
            name = text.take(50),
            calories = calories,
            protein = protein,
            carbs = carbs,
            fat = fat,
            fiber = 2.0,
            sugar = 5.0,
            sodium = 100.0,
            confidence = 0.6,
            source = "mock_analysis"
        )
    }
}

/**
 * Custom exception for AI service errors
 */
class AIServiceException(
    message: String,
    cause: Throwable? = null
) : Exception(message, cause)
