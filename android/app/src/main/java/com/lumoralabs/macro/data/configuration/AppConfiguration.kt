package com.lumoralabs.macro.data.configuration

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.lumoralabs.macro.data.services.ConfigurationServiceProtocol

/**
 * Secure Configuration Manager for MACRO Android App
 * 
 * Handles API keys and sensitive configuration securely using:
 * 1. Environment variables (development)
 * 2. Encrypted SharedPreferences (production)
 * 3. BuildConfig values (fallback)
 * 
 * Security Features:
 * - No hardcoded API keys
 * - Encrypted storage for production
 * - Environment variable support
 * - Runtime validation
 * - Secure storage practices using Android Keystore
 */
class AppConfiguration private constructor(
    private val context: Context
) : ConfigurationServiceProtocol {
    
    companion object {
        @Volatile
        private var INSTANCE: AppConfiguration? = null
        
        fun getInstance(context: Context): AppConfiguration {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: AppConfiguration(context.applicationContext).also { INSTANCE = it }
            }
        }
        
        // Configuration Keys
        private const val PREFS_NAME = "macro_secure_config"
        private const val OPENAI_API_KEY = "OPENAI_API_KEY"
        private const val ANTHROPIC_API_KEY = "ANTHROPIC_API_KEY"
        private const val USDA_API_KEY = "USDA_API_KEY"
        private const val EDAMAM_APP_ID = "EDAMAM_APP_ID"
        private const val EDAMAM_APP_KEY = "EDAMAM_APP_KEY"
        private const val ENABLE_ANALYTICS = "ENABLE_ANALYTICS"
        private const val ENABLE_LOGGING = "ENABLE_LOGGING"
        private const val API_BASE_URL = "API_BASE_URL"
    }
    
    private val encryptedPrefs: SharedPreferences by lazy {
        createEncryptedPreferences()
    }
    
    // MARK: - Public Configuration Properties
    
    /**
     * OpenAI API key for AI services
     */
    val openAIAPIKey: String
        get() = getSecureValue(OPENAI_API_KEY)
    
    /**
     * Anthropic API key for Claude AI
     */
    val anthropicAPIKey: String
        get() = getSecureValue(ANTHROPIC_API_KEY)
    
    /**
     * USDA nutrition database API key
     */
    val usdaAPIKey: String
        get() = getSecureValue(USDA_API_KEY)
    
    /**
     * Edamam nutrition API app ID
     */
    val edamamAppID: String
        get() = getSecureValue(EDAMAM_APP_ID)
    
    /**
     * Edamam nutrition API key
     */
    val edamamAppKey: String
        get() = getSecureValue(EDAMAM_APP_KEY)
    
    /**
     * Enable analytics collection
     */
    val enableAnalytics: Boolean
        get() = getBooleanValue(ENABLE_ANALYTICS, defaultValue = !isDebugMode())
    
    /**
     * Enable debug logging
     */
    val enableLogging: Boolean
        get() = getBooleanValue(ENABLE_LOGGING, defaultValue = isDebugMode())
    
    /**
     * API base URL
     */
    val apiBaseURL: String
        get() = getSecureValue(API_BASE_URL).ifEmpty { "https://api.lumoralabs.com" }
    
    // MARK: - ConfigurationServiceProtocol Implementation
    
    override fun getString(key: String): String? {
        return getSecureValue(key).takeIf { it.isNotEmpty() }
    }
    
    override fun getBoolean(key: String, defaultValue: Boolean): Boolean {
        return getBooleanValue(key, defaultValue)
    }
    
    override fun getInt(key: String, defaultValue: Int): Int {
        return try {
            getSecureValue(key).toInt()
        } catch (e: NumberFormatException) {
            defaultValue
        }
    }
    
    override fun hasAIConfiguration(): Boolean {
        return openAIAPIKey.isNotEmpty() || anthropicAPIKey.isNotEmpty()
    }
    
    override fun hasNutritionAPIs(): Boolean {
        return usdaAPIKey.isNotEmpty() || (edamamAppID.isNotEmpty() && edamamAppKey.isNotEmpty())
    }
    
    override fun getConfigurationStatus(): Map<String, Boolean> {
        return mapOf(
            "OpenAI" to openAIAPIKey.isNotEmpty(),
            "Anthropic" to anthropicAPIKey.isNotEmpty(),
            "USDA" to usdaAPIKey.isNotEmpty(),
            "Edamam" to (edamamAppID.isNotEmpty() && edamamAppKey.isNotEmpty()),
            "Production" to !isDebugMode()
        )
    }
    
    // MARK: - Secure Value Loading
    
    private fun getSecureValue(key: String): String {
        // Priority order:
        // 1. Environment variables (development)
        // 2. Encrypted SharedPreferences (production)
        // 3. BuildConfig values (fallback)
        
        // Check environment variables first (development)
        System.getenv(key)?.takeIf { it.isNotEmpty() }?.let { return it }
        
        // Check encrypted preferences (production)
        encryptedPrefs.getString(key, null)?.takeIf { it.isNotEmpty() }?.let { return it }
        
        // Check BuildConfig as fallback
        getBuildConfigValue(key)?.takeIf { it.isNotEmpty() }?.let { return it }
        
        return ""
    }
    
    private fun getBooleanValue(key: String, defaultValue: Boolean): Boolean {
        val stringValue = getSecureValue(key)
        return when {
            stringValue.isEmpty() -> defaultValue
            stringValue.equals("true", ignoreCase = true) -> true
            stringValue.equals("false", ignoreCase = true) -> false
            else -> defaultValue
        }
    }
    
    // MARK: - Encrypted Storage Management
    
    private fun createEncryptedPreferences(): SharedPreferences {
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()
        
        return EncryptedSharedPreferences.create(
            context,
            PREFS_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }
    
    /**
     * Store API key securely (for production setup)
     */
    fun setSecureValue(key: String, value: String): Boolean {
        return try {
            encryptedPrefs.edit()
                .putString(key, value)
                .apply()
            true
        } catch (e: Exception) {
            android.util.Log.e("AppConfiguration", "Failed to store secure value", e)
            false
        }
    }
    
    /**
     * Remove stored API key
     */
    fun removeSecureValue(key: String): Boolean {
        return try {
            encryptedPrefs.edit()
                .remove(key)
                .apply()
            true
        } catch (e: Exception) {
            android.util.Log.e("AppConfiguration", "Failed to remove secure value", e)
            false
        }
    }
    
    /**
     * Clear all stored configuration
     */
    fun clearAllSecureValues(): Boolean {
        return try {
            encryptedPrefs.edit()
                .clear()
                .apply()
            true
        } catch (e: Exception) {
            android.util.Log.e("AppConfiguration", "Failed to clear secure values", e)
            false
        }
    }
    
    // MARK: - Utility Methods
    
    private fun isDebugMode(): Boolean {
        return try {
            val buildConfigClass = Class.forName("com.lumoralabs.macro.BuildConfig")
            val debugField = buildConfigClass.getField("DEBUG")
            debugField.getBoolean(null)
        } catch (e: Exception) {
            false
        }
    }
    
    private fun getBuildConfigValue(key: String): String? {
        return try {
            val buildConfigClass = Class.forName("com.lumoralabs.macro.BuildConfig")
            val field = buildConfigClass.getField(key)
            field.get(null) as? String
        } catch (e: Exception) {
            null
        }
    }
    
    // MARK: - Development Helpers
    
    /**
     * Print configuration status for debugging
     */
    fun printConfigurationStatus() {
        if (isDebugMode()) {
            android.util.Log.d("MacroConfig", "🔧 MACRO Configuration Status:")
            android.util.Log.d("MacroConfig", "  🤖 OpenAI API: ${if (openAIAPIKey.isNotEmpty()) "✅ Configured" else "❌ Missing"}")
            android.util.Log.d("MacroConfig", "  🧠 Anthropic API: ${if (anthropicAPIKey.isNotEmpty()) "✅ Configured" else "❌ Missing"}")
            android.util.Log.d("MacroConfig", "  🥗 USDA API: ${if (usdaAPIKey.isNotEmpty()) "✅ Configured" else "❌ Missing"}")
            android.util.Log.d("MacroConfig", "  📊 Edamam API: ${if (edamamAppID.isNotEmpty() && edamamAppKey.isNotEmpty()) "✅ Configured" else "❌ Missing"}")
            android.util.Log.d("MacroConfig", "  🏭 Environment: ${if (isDebugMode()) "Development" else "Production"}")
            android.util.Log.d("MacroConfig", "  📱 Analytics: ${if (enableAnalytics) "Enabled" else "Disabled"}")
        }
    }
    
    /**
     * Setup development keys helper
     */
    fun setupDevelopmentKeys() {
        if (isDebugMode()) {
            android.util.Log.d("MacroConfig", "⚠️ Remember to configure your API keys:")
            android.util.Log.d("MacroConfig", "1. Set environment variables, OR")
            android.util.Log.d("MacroConfig", "2. Use setSecureValue() method, OR") 
            android.util.Log.d("MacroConfig", "3. Add keys to BuildConfig")
            android.util.Log.d("MacroConfig", "📖 See API_SETUP.md for detailed instructions")
        }
    }
}

/**
 * Configuration helper extensions
 */
object ConfigurationHelper {
    
    /**
     * API endpoint configurations
     */
    object Endpoints {
        const val OPENAI_BASE_URL = "https://api.openai.com/v1"
        const val ANTHROPIC_BASE_URL = "https://api.anthropic.com/v1"
        const val USDA_BASE_URL = "https://api.nal.usda.gov/fdc/v1"
        const val EDAMAM_BASE_URL = "https://api.edamam.com/api/nutrition-details"
    }
    
    /**
     * Default configuration values
     */
    object Defaults {
        const val REQUEST_TIMEOUT_MS = 30000L
        const val CACHE_EXPIRATION_MS = 3600000L // 1 hour
        const val MAX_CACHE_SIZE_MB = 100L
        const val AI_CONFIDENCE_THRESHOLD = 0.7
    }
    
    /**
     * Configuration keys for external access
     */
    object Keys {
        const val OPENAI_API_KEY = "OPENAI_API_KEY"
        const val ANTHROPIC_API_KEY = "ANTHROPIC_API_KEY"
        const val USDA_API_KEY = "USDA_API_KEY"
        const val EDAMAM_APP_ID = "EDAMAM_APP_ID"
        const val EDAMAM_APP_KEY = "EDAMAM_APP_KEY"
    }
}
