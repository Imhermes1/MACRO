package com.lumoralabs.macro.data.services.implementation

import android.content.Context
import android.util.Log
import com.lumoralabs.macro.data.configuration.AppConfiguration
import com.lumoralabs.macro.data.models.*
import com.lumoralabs.macro.data.services.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

/**
 * Android Nutrition Service Implementation
 * 
 * Comprehensive nutrition analysis service that coordinates AI analysis,
 * database storage, and caching for optimal performance
 */
class AndroidNutritionService(
    private val aiService: AIServiceProtocol,
    private val databaseService: DatabaseServiceProtocol,
    private val cacheService: CacheServiceProtocol,
    private val configuration: AppConfiguration
) : NutritionServiceProtocol {
    
    companion object {
        private const val TAG = "AndroidNutritionService"
        private const val CACHE_EXPIRATION_MS = 24 * 60 * 60 * 1000L // 24 hours
        private const val BARCODE_CACHE_PREFIX = "barcode_"
        private const val ANALYSIS_CACHE_PREFIX = "analysis_"
        private const val MIN_CONFIDENCE_THRESHOLD = 0.5
    }
    
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }
    
    // MARK: - State Management
    
    private val _serviceState = MutableStateFlow<ServiceState>(ServiceState.Idle)
    override val serviceState: Flow<ServiceState> = _serviceState.asStateFlow()
    
    init {
        Log.d(TAG, "AndroidNutritionService initialized")
    }
    
    // MARK: - NutritionServiceProtocol Implementation
    
    override suspend fun analyzeTextInput(text: String): Result<NutritionData> {
        Log.d(TAG, "Analyzing text input: ${text.take(50)}...")
        
        _serviceState.value = ServiceState.Loading
        
        return try {
            // Check cache first
            val cacheKey = ANALYSIS_CACHE_PREFIX + text.hashCode()
            val cachedResult = cacheService.get(cacheKey, NutritionData::class.java).getOrNull()
            
            if (cachedResult != null) {
                Log.d(TAG, "Using cached nutrition analysis")
                _serviceState.value = ServiceState.Success("Loaded from cache")
                return Result.success(cachedResult)
            }
            
            // Perform AI analysis
            val analysisResult = aiService.analyzeText(text, AnalysisContext.TEXT)
            
            if (analysisResult.isFailure) {
                val error = analysisResult.exceptionOrNull() ?: Exception("AI analysis failed")
                _serviceState.value = ServiceState.Error(error)
                return Result.failure(error)
            }
            
            // Parse nutrition data from AI response
            val aiResult = analysisResult.getOrThrow()
            val nutritionData = parseNutritionFromAI(aiResult)
            
            if (nutritionData.confidence < MIN_CONFIDENCE_THRESHOLD) {
                Log.w(TAG, "Low confidence analysis: ${nutritionData.confidence}")
            }
            
            // Cache the result
            cacheService.set(cacheKey, nutritionData, CACHE_EXPIRATION_MS)
            
            // Save to database
            val saveResult = databaseService.save(nutritionData)
            if (saveResult is DatabaseResult.Error) {
                Log.w(TAG, "Failed to save nutrition data to database", saveResult.exception)
            }
            
            _serviceState.value = ServiceState.Success("Analysis completed")
            Result.success(nutritionData)
            
        } catch (e: Exception) {
            Log.e(TAG, "Text analysis error", e)
            _serviceState.value = ServiceState.Error(e)
            Result.failure(e)
        }
    }
    
    override suspend fun analyzeImageInput(imageData: ByteArray, description: String): Result<NutritionData> {
        Log.d(TAG, "Analyzing image input (${imageData.size} bytes)")
        
        _serviceState.value = ServiceState.Loading
        
        return try {
            // Generate cache key based on image hash and description
            val imageHash = imageData.contentHashCode()
            val cacheKey = "${ANALYSIS_CACHE_PREFIX}img_${imageHash}_${description.hashCode()}"
            
            // Check cache first
            val cachedResult = cacheService.get(cacheKey, NutritionData::class.java).getOrNull()
            if (cachedResult != null) {
                Log.d(TAG, "Using cached image analysis")
                _serviceState.value = ServiceState.Success("Loaded from cache")
                return Result.success(cachedResult)
            }
            
            // Perform AI image analysis
            val prompt = if (description.isNotEmpty()) {
                "Analyze this food image and provide nutrition information. Context: $description"
            } else {
                "Analyze this food image and provide nutrition information."
            }
            
            val analysisResult = aiService.analyzeImage(imageData, prompt)
            
            if (analysisResult.isFailure) {
                val error = analysisResult.exceptionOrNull() ?: Exception("Image analysis failed")
                _serviceState.value = ServiceState.Error(error)
                return Result.failure(error)
            }
            
            // Parse nutrition data from AI response
            val aiResult = analysisResult.getOrThrow()
            val nutritionData = parseNutritionFromAI(aiResult)
            
            // Cache the result
            cacheService.set(cacheKey, nutritionData, CACHE_EXPIRATION_MS)
            
            // Save to database
            val saveResult = databaseService.save(nutritionData)
            if (saveResult is DatabaseResult.Error) {
                Log.w(TAG, "Failed to save image analysis to database", saveResult.exception)
            }
            
            _serviceState.value = ServiceState.Success("Image analysis completed")
            Result.success(nutritionData)
            
        } catch (e: Exception) {
            Log.e(TAG, "Image analysis error", e)
            _serviceState.value = ServiceState.Error(e)
            Result.failure(e)
        }
    }
    
    override suspend fun lookupBarcode(barcode: String): Result<NutritionData> {
        Log.d(TAG, "Looking up barcode: $barcode")
        
        _serviceState.value = ServiceState.Loading
        
        return try {
            // Check local database first
            if (databaseService is AndroidDatabaseService) {
                val dbResult = databaseService.fetchByBarcode(barcode)
                if (dbResult is DatabaseResult.Success && dbResult.data != null) {
                    Log.d(TAG, "Found barcode in local database")
                    _serviceState.value = ServiceState.Success("Found in database")
                    return Result.success(dbResult.data)
                }
            }
            
            // Check cache
            val cacheKey = BARCODE_CACHE_PREFIX + barcode
            val cachedResult = cacheService.get(cacheKey, NutritionData::class.java).getOrNull()
            if (cachedResult != null) {
                Log.d(TAG, "Found barcode in cache")
                _serviceState.value = ServiceState.Success("Found in cache")
                return Result.success(cachedResult)
            }
            
            // Try external barcode lookup APIs
            val nutritionData = lookupBarcodeExternal(barcode)
            
            if (nutritionData != null) {
                // Cache and save successful lookup
                cacheService.set(cacheKey, nutritionData, CACHE_EXPIRATION_MS)
                databaseService.save(nutritionData)
                
                _serviceState.value = ServiceState.Success("Barcode lookup completed")
                Result.success(nutritionData)
            } else {
                val error = Exception("Barcode not found: $barcode")
                _serviceState.value = ServiceState.Error(error)
                Result.failure(error)
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Barcode lookup error", e)
            _serviceState.value = ServiceState.Error(e)
            Result.failure(e)
        }
    }
    
    override suspend fun analyzeRecipe(recipe: String, servings: Int): Result<NutritionData> {
        Log.d(TAG, "Analyzing recipe for $servings servings")
        
        _serviceState.value = ServiceState.Loading
        
        return try {
            // Check cache
            val cacheKey = "${ANALYSIS_CACHE_PREFIX}recipe_${recipe.hashCode()}_$servings"
            val cachedResult = cacheService.get(cacheKey, NutritionData::class.java).getOrNull()
            if (cachedResult != null) {
                Log.d(TAG, "Using cached recipe analysis")
                _serviceState.value = ServiceState.Success("Loaded from cache")
                return Result.success(cachedResult)
            }
            
            // Enhance recipe prompt for better AI analysis
            val enhancedPrompt = """
                Analyze this recipe and provide per-serving nutrition information for $servings servings total.
                
                Recipe:
                $recipe
                
                Please calculate nutrition values per single serving.
            """.trimIndent()
            
            // Perform AI analysis
            val analysisResult = aiService.analyzeText(enhancedPrompt, AnalysisContext.RECIPE)
            
            if (analysisResult.isFailure) {
                val error = analysisResult.exceptionOrNull() ?: Exception("Recipe analysis failed")
                _serviceState.value = ServiceState.Error(error)
                return Result.failure(error)
            }
            
            // Parse nutrition data from AI response
            val aiResult = analysisResult.getOrThrow()
            val nutritionData = parseNutritionFromAI(aiResult).copy(
                name = extractRecipeName(recipe),
                source = "recipe_analysis",
                servingSize = "1 serving",
                servingUnit = "serving"
            )
            
            // Cache the result
            cacheService.set(cacheKey, nutritionData, CACHE_EXPIRATION_MS)
            
            // Save to database
            val saveResult = databaseService.save(nutritionData)
            if (saveResult is DatabaseResult.Error) {
                Log.w(TAG, "Failed to save recipe analysis to database", saveResult.exception)
            }
            
            _serviceState.value = ServiceState.Success("Recipe analysis completed")
            Result.success(nutritionData)
            
        } catch (e: Exception) {
            Log.e(TAG, "Recipe analysis error", e)
            _serviceState.value = ServiceState.Error(e)
            Result.failure(e)
        }
    }
    
    override suspend fun getNutritionHistory(): Result<List<NutritionData>> {
        Log.d(TAG, "Fetching nutrition history")
        
        return try {
            val dbResult = databaseService.fetchAll()
            
            when (dbResult) {
                is DatabaseResult.Success -> {
                    Log.d(TAG, "Retrieved ${dbResult.data.size} nutrition entries")
                    Result.success(dbResult.data)
                }
                is DatabaseResult.Error -> {
                    Log.e(TAG, "Failed to fetch nutrition history", dbResult.exception)
                    Result.failure(dbResult.exception)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Nutrition history error", e)
            Result.failure(e)
        }
    }
    
    override suspend fun saveNutritionEntry(data: NutritionData): Result<Unit> {
        Log.d(TAG, "Saving nutrition entry: ${data.name}")
        
        return try {
            val dbResult = databaseService.save(data)
            
            when (dbResult) {
                is DatabaseResult.Success -> {
                    Log.d(TAG, "Successfully saved nutrition entry")
                    Result.success(Unit)
                }
                is DatabaseResult.Error -> {
                    Log.e(TAG, "Failed to save nutrition entry", dbResult.exception)
                    Result.failure(dbResult.exception)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Save nutrition entry error", e)
            Result.failure(e)
        }
    }
    
    override suspend fun deleteNutritionEntry(id: String): Result<Unit> {
        Log.d(TAG, "Deleting nutrition entry: $id")
        
        return try {
            val dbResult = databaseService.deleteById(id)
            
            when (dbResult) {
                is DatabaseResult.Success -> {
                    Log.d(TAG, "Successfully deleted nutrition entry")
                    Result.success(Unit)
                }
                is DatabaseResult.Error -> {
                    Log.e(TAG, "Failed to delete nutrition entry", dbResult.exception)
                    Result.failure(dbResult.exception)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Delete nutrition entry error", e)
            Result.failure(e)
        }
    }
    
    override suspend fun searchNutritionEntries(query: String): Result<List<NutritionData>> {
        Log.d(TAG, "Searching nutrition entries: $query")
        
        return try {
            val dbResult = databaseService.search(query)
            
            when (dbResult) {
                is DatabaseResult.Success -> {
                    Log.d(TAG, "Search returned ${dbResult.data.size} results")
                    Result.success(dbResult.data)
                }
                is DatabaseResult.Error -> {
                    Log.e(TAG, "Failed to search nutrition entries", dbResult.exception)
                    Result.failure(dbResult.exception)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Search nutrition entries error", e)
            Result.failure(e)
        }
    }
    
    override suspend fun getNutritionSummary(startTime: Long, endTime: Long): Result<NutritionSummary> {
        Log.d(TAG, "Calculating nutrition summary for date range")
        
        return try {
            val dbResult = databaseService.fetchByDateRange(startTime, endTime)
            
            when (dbResult) {
                is DatabaseResult.Success -> {
                    val entries = dbResult.data
                    val summary = calculateNutritionSummary(entries, startTime, endTime)
                    
                    Log.d(TAG, "Calculated summary for ${entries.size} entries")
                    Result.success(summary)
                }
                is DatabaseResult.Error -> {
                    Log.e(TAG, "Failed to fetch nutrition for summary", dbResult.exception)
                    Result.failure(dbResult.exception)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Nutrition summary error", e)
            Result.failure(e)
        }
    }
    
    // MARK: - Helper Methods
    
    private fun parseNutritionFromAI(aiResult: AIAnalysisResult): NutritionData {
        return try {
            // Try to parse as direct NutritionData JSON
            json.decodeFromString<NutritionData>(aiResult.content)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to parse AI result as NutritionData, attempting extraction", e)
            
            // Fallback: extract nutrition info from text response
            extractNutritionFromText(aiResult.content, aiResult.confidence)
        }
    }
    
    private fun extractNutritionFromText(content: String, confidence: Double): NutritionData {
        // Simple extraction logic for when AI doesn't return proper JSON
        return NutritionData(
            name = "AI Analysis Result",
            calories = extractNumber(content, listOf("calories", "cal", "kcal")) ?: 100.0,
            protein = extractNumber(content, listOf("protein", "prot")) ?: 5.0,
            carbs = extractNumber(content, listOf("carbs", "carbohydrates", "carb")) ?: 15.0,
            fat = extractNumber(content, listOf("fat", "fats", "lipid")) ?: 3.0,
            fiber = extractNumber(content, listOf("fiber", "fibre")),
            sugar = extractNumber(content, listOf("sugar", "sugars")),
            sodium = extractNumber(content, listOf("sodium", "salt")),
            confidence = confidence,
            source = "ai_extraction"
        )
    }
    
    private fun extractNumber(text: String, keywords: List<String>): Double? {
        for (keyword in keywords) {
            val regex = Regex("$keyword[:\\s]*([0-9.]+)", RegexOption.IGNORE_CASE)
            val match = regex.find(text)
            if (match != null) {
                return match.groupValues[1].toDoubleOrNull()
            }
        }
        return null
    }
    
    private suspend fun lookupBarcodeExternal(barcode: String): NutritionData? {
        // Placeholder for external barcode API integration
        // In a real implementation, you would integrate with services like:
        // - Open Food Facts API
        // - USDA FoodData Central
        // - Edamam Food Database
        
        Log.d(TAG, "External barcode lookup not implemented yet")
        return null
    }
    
    private fun extractRecipeName(recipe: String): String {
        // Extract recipe name from the first line or first few words
        val lines = recipe.trim().split("\n")
        val firstLine = lines.firstOrNull()?.trim() ?: "Recipe"
        
        // Take first 50 characters as recipe name
        return if (firstLine.length > 50) {
            firstLine.take(47) + "..."
        } else {
            firstLine
        }
    }
    
    private fun calculateNutritionSummary(
        entries: List<NutritionData>,
        startTime: Long,
        endTime: Long
    ): NutritionSummary {
        if (entries.isEmpty()) {
            return NutritionSummary(
                totalCalories = 0.0,
                totalProtein = 0.0,
                totalCarbs = 0.0,
                totalFat = 0.0,
                totalFiber = 0.0,
                entryCount = 0,
                averageConfidence = 0.0,
                dateRange = Pair(startTime, endTime)
            )
        }
        
        return NutritionSummary(
            totalCalories = entries.sumOf { it.calories },
            totalProtein = entries.sumOf { it.protein },
            totalCarbs = entries.sumOf { it.carbs },
            totalFat = entries.sumOf { it.fat },
            totalFiber = entries.sumOf { it.fiber ?: 0.0 },
            entryCount = entries.size,
            averageConfidence = entries.map { it.confidence }.average(),
            dateRange = Pair(startTime, endTime)
        )
    }
    
    // MARK: - Advanced Features
    
    /**
     * Get nutrition data stream for real-time UI updates
     */
    fun getNutritionStream(): Flow<List<NutritionData>> {
        return if (databaseService is AndroidDatabaseService) {
            databaseService.getNutritionFlow()
        } else {
            kotlinx.coroutines.flow.flowOf(emptyList())
        }
    }
    
    /**
     * Get combined service status for monitoring
     */
    fun getServiceStatus(): Flow<ServiceStatus> {
        return combine(
            serviceState,
            aiService.isProcessing,
            aiService.lastError
        ) { nutritionState, aiProcessing, aiError ->
            ServiceStatus(
                nutritionServiceState = nutritionState,
                aiServiceProcessing = aiProcessing,
                lastError = aiError,
                hasConfiguration = configuration.hasAIConfiguration()
            )
        }
    }
}

/**
 * Combined service status for monitoring
 */
data class ServiceStatus(
    val nutritionServiceState: ServiceState,
    val aiServiceProcessing: Boolean,
    val lastError: Throwable?,
    val hasConfiguration: Boolean
) {
    val isHealthy: Boolean
        get() = !nutritionServiceState.isError && lastError == null && hasConfiguration
}
