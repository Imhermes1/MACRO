package com.lumoralabs.macro.data.services

import com.lumoralabs.macro.data.models.*
import kotlinx.coroutines.flow.Flow

/**
 * AI Service Protocol for nutrition analysis
 * 
 * Defines the contract for AI-powered food analysis services
 * supporting text, image, and other input modalities
 */
interface AIServiceProtocol {
    
    /**
     * Processing state for UI observability
     */
    val isProcessing: Flow<Boolean>
    
    /**
     * Last error for error handling
     */
    val lastError: Flow<Throwable?>
    
    /**
     * Analyze text description of food
     */
    suspend fun analyzeText(text: String, context: AnalysisContext): Result<AIAnalysisResult>
    
    /**
     * Analyze image of food
     */
    suspend fun analyzeImage(imageData: ByteArray, prompt: String): Result<AIAnalysisResult>
    
    /**
     * Generate conversational response
     */
    suspend fun generateResponse(prompt: String, context: AnalysisContext): Result<String>
}

/**
 * Database Service Protocol for persistent storage
 */
interface DatabaseServiceProtocol {
    
    /**
     * Save nutrition data to persistent storage
     */
    suspend fun save(data: NutritionData): DatabaseResult<Unit>
    
    /**
     * Save multiple nutrition entries
     */
    suspend fun saveAll(data: List<NutritionData>): DatabaseResult<Unit>
    
    /**
     * Fetch all nutrition data
     */
    suspend fun fetchAll(): DatabaseResult<List<NutritionData>>
    
    /**
     * Fetch nutrition data by ID
     */
    suspend fun fetchById(id: String): DatabaseResult<NutritionData?>
    
    /**
     * Delete nutrition entry by ID
     */
    suspend fun deleteById(id: String): DatabaseResult<Unit>
    
    /**
     * Clear all nutrition data
     */
    suspend fun clear(): DatabaseResult<Unit>
    
    /**
     * Search nutrition entries by name
     */
    suspend fun search(query: String): DatabaseResult<List<NutritionData>>
    
    /**
     * Get nutrition entries for date range
     */
    suspend fun fetchByDateRange(startTime: Long, endTime: Long): DatabaseResult<List<NutritionData>>
}

/**
 * Cache Service Protocol for temporary data storage
 */
interface CacheServiceProtocol {
    
    /**
     * Store value in cache with expiration
     */
    suspend fun <T> set(key: String, value: T, expirationMs: Long = 3600000): Result<Unit>
    
    /**
     * Retrieve value from cache
     */
    suspend fun <T> get(key: String, type: Class<T>): Result<T?>
    
    /**
     * Remove value from cache
     */
    suspend fun remove(key: String): Result<Unit>
    
    /**
     * Clear all cached data
     */
    suspend fun clear(): Result<Unit>
    
    /**
     * Get cache size in bytes
     */
    suspend fun size(): Result<Long>
    
    /**
     * Check if key exists in cache
     */
    suspend fun contains(key: String): Result<Boolean>
}

/**
 * Nutrition Service Protocol for comprehensive food analysis
 */
interface NutritionServiceProtocol {
    
    /**
     * Service state for UI observability
     */
    val serviceState: Flow<ServiceState>
    
    /**
     * Analyze text description and return nutrition data
     */
    suspend fun analyzeTextInput(text: String): Result<NutritionData>
    
    /**
     * Analyze image and return nutrition data
     */
    suspend fun analyzeImageInput(imageData: ByteArray, description: String = ""): Result<NutritionData>
    
    /**
     * Look up nutrition data by barcode
     */
    suspend fun lookupBarcode(barcode: String): Result<NutritionData>
    
    /**
     * Analyze recipe and return per-serving nutrition
     */
    suspend fun analyzeRecipe(recipe: String, servings: Int): Result<NutritionData>
    
    /**
     * Get nutrition history
     */
    suspend fun getNutritionHistory(): Result<List<NutritionData>>
    
    /**
     * Save nutrition entry
     */
    suspend fun saveNutritionEntry(data: NutritionData): Result<Unit>
    
    /**
     * Delete nutrition entry
     */
    suspend fun deleteNutritionEntry(id: String): Result<Unit>
    
    /**
     * Search saved nutrition entries
     */
    suspend fun searchNutritionEntries(query: String): Result<List<NutritionData>>
    
    /**
     * Get nutrition summary for date range
     */
    suspend fun getNutritionSummary(startTime: Long, endTime: Long): Result<NutritionSummary>
}

/**
 * Configuration Service Protocol for secure app configuration
 */
interface ConfigurationServiceProtocol {
    
    /**
     * Get configuration value
     */
    fun getString(key: String): String?
    
    /**
     * Get boolean configuration value
     */
    fun getBoolean(key: String, defaultValue: Boolean = false): Boolean
    
    /**
     * Get integer configuration value
     */
    fun getInt(key: String, defaultValue: Int = 0): Int
    
    /**
     * Check if configuration has required API keys
     */
    fun hasAIConfiguration(): Boolean
    
    /**
     * Check if nutrition APIs are configured
     */
    fun hasNutritionAPIs(): Boolean
    
    /**
     * Get configuration status
     */
    fun getConfigurationStatus(): Map<String, Boolean>
}

/**
 * Nutrition summary for analytics
 */
data class NutritionSummary(
    val totalCalories: Double,
    val totalProtein: Double,
    val totalCarbs: Double,
    val totalFat: Double,
    val totalFiber: Double,
    val entryCount: Int,
    val averageConfidence: Double,
    val dateRange: Pair<Long, Long>
)
