package com.lumoralabs.macro.data.models

import kotlinx.serialization.Serializable
import java.util.UUID

/**
 * Core nutrition data model for MACRO Android app
 * 
 * Represents nutritional information for food items with support for
 * various input sources (text, image, barcode, recipe analysis)
 */
@Serializable
data class NutritionData(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val brand: String? = null,
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double? = null,
    val sugar: Double? = null,
    val sodium: Double? = null,
    val confidence: Double = 1.0,
    val source: String = "manual",
    val barcode: String? = null,
    val servingSize: String? = null,
    val servingUnit: String? = null,
    val timestamp: Long = System.currentTimeMillis()
) {
    /**
     * Calculate total macronutrient calories
     */
    val macroCalories: Double
        get() = (protein * 4) + (carbs * 4) + (fat * 9)
    
    /**
     * Validate nutrition data integrity
     */
    fun isValid(): Boolean {
        return name.isNotBlank() &&
                calories >= 0 &&
                protein >= 0 &&
                carbs >= 0 &&
                fat >= 0 &&
                confidence in 0.0..1.0
    }
    
    /**
     * Create a copy with updated values
     */
    fun withUpdatedNutrition(
        calories: Double = this.calories,
        protein: Double = this.protein,
        carbs: Double = this.carbs,
        fat: Double = this.fat
    ): NutritionData {
        return copy(
            calories = calories,
            protein = protein,
            carbs = carbs,
            fat = fat
        )
    }
}

/**
 * AI analysis result containing nutrition data and metadata
 */
@Serializable
data class AIAnalysisResult(
    val content: String,
    val confidence: Double,
    val metadata: Map<String, String> = emptyMap(),
    val timestamp: Long = System.currentTimeMillis()
) {
    /**
     * Parse nutrition data from AI analysis content
     */
    fun parseNutritionData(): NutritionData? {
        return try {
            kotlinx.serialization.json.Json.decodeFromString<NutritionData>(content)
        } catch (e: Exception) {
            null
        }
    }
}

/**
 * Analysis context for AI processing
 */
enum class AnalysisContext {
    TEXT,
    IMAGE,
    BARCODE,
    RECIPE;
    
    val displayName: String
        get() = when (this) {
            TEXT -> "Text Analysis"
            IMAGE -> "Image Analysis"
            BARCODE -> "Barcode Lookup"
            RECIPE -> "Recipe Analysis"
        }
}

/**
 * Cache entry for storing temporary data
 */
@Serializable
data class CacheEntry<T>(
    val key: String,
    val value: T,
    val expirationTime: Long,
    val timestamp: Long = System.currentTimeMillis()
) {
    /**
     * Check if cache entry is expired
     */
    fun isExpired(): Boolean = System.currentTimeMillis() > expirationTime
    
    /**
     * Check if cache entry is still valid
     */
    fun isValid(): Boolean = !isExpired()
}

/**
 * Database query result wrapper
 */
sealed class DatabaseResult<T> {
    data class Success<T>(val data: T) : DatabaseResult<T>()
    data class Error<T>(val exception: Throwable) : DatabaseResult<T>()
    
    /**
     * Execute action if result is successful
     */
    inline fun onSuccess(action: (T) -> Unit): DatabaseResult<T> {
        if (this is Success) action(data)
        return this
    }
    
    /**
     * Execute action if result is error
     */
    inline fun onError(action: (Throwable) -> Unit): DatabaseResult<T> {
        if (this is Error) action(exception)
        return this
    }
    
    /**
     * Get data or return default value
     */
    fun getOrDefault(default: T): T {
        return when (this) {
            is Success -> data
            is Error -> default
        }
    }
    
    /**
     * Get data or null
     */
    fun getOrNull(): T? {
        return when (this) {
            is Success -> data
            is Error -> null
        }
    }
}

/**
 * Service state for UI observability
 */
sealed class ServiceState {
    object Idle : ServiceState()
    object Loading : ServiceState()
    data class Success(val message: String? = null) : ServiceState()
    data class Error(val exception: Throwable) : ServiceState()
    
    val isLoading: Boolean get() = this is Loading
    val isError: Boolean get() = this is Error
    val isSuccess: Boolean get() = this is Success
}
