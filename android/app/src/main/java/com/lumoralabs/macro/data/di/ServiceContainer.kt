package com.lumoralabs.macro.data.di

import android.content.Context
import com.lumoralabs.macro.data.configuration.AppConfiguration
import com.lumoralabs.macro.data.services.*
import com.lumoralabs.macro.data.services.implementation.*
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

/**
 * Service Container for MACRO Android App
 * 
 * Provides centralized dependency injection for all application services
 * using Dagger Hilt for modern Android architecture
 * 
 * Features:
 * - Singleton service instances
 * - Automatic configuration detection
 * - Production vs Mock service selection
 * - Clean dependency management
 */
@Module
@InstallIn(SingletonComponent::class)
object ServiceModule {
    
    /**
     * Provide application configuration
     */
    @Provides
    @Singleton
    fun provideAppConfiguration(
        @ApplicationContext context: Context
    ): AppConfiguration = AppConfiguration.getInstance(context)
    
    /**
     * Provide AI service implementation based on configuration
     */
    @Provides
    @Singleton
    fun provideAIService(
        @ApplicationContext context: Context,
        configuration: AppConfiguration
    ): AIServiceProtocol {
        return if (configuration.hasAIConfiguration()) {
            // Use production AI service when API keys are available
            ProductionAIService(context, configuration)
        } else {
            // Fall back to mock service for development
            MockAIService(context)
        }
    }
    
    /**
     * Provide database service
     */
    @Provides
    @Singleton
    fun provideDatabaseService(
        @ApplicationContext context: Context
    ): DatabaseServiceProtocol = AndroidDatabaseService(context)
    
    /**
     * Provide cache service
     */
    @Provides
    @Singleton
    fun provideCacheService(
        @ApplicationContext context: Context
    ): CacheServiceProtocol = AndroidCacheService(context)
    
    /**
     * Provide nutrition service
     */
    @Provides
    @Singleton
    fun provideNutritionService(
        aiService: AIServiceProtocol,
        databaseService: DatabaseServiceProtocol,
        cacheService: CacheServiceProtocol,
        configuration: AppConfiguration
    ): NutritionServiceProtocol = AndroidNutritionService(
        aiService = aiService,
        databaseService = databaseService,
        cacheService = cacheService,
        configuration = configuration
    )
}

/**
 * Service Container - Legacy singleton pattern for services that need
 * to be accessed without Hilt injection
 */
class ServiceContainer private constructor(
    private val context: Context
) {
    companion object {
        @Volatile
        private var INSTANCE: ServiceContainer? = null
        
        fun getInstance(context: Context): ServiceContainer {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: ServiceContainer(context.applicationContext).also { INSTANCE = it }
            }
        }
    }
    
    // MARK: - Service Instances
    
    private val _configuration: AppConfiguration by lazy {
        AppConfiguration.getInstance(context)
    }
    
    private val _aiService: AIServiceProtocol by lazy {
        if (_configuration.hasAIConfiguration()) {
            ProductionAIService(context, _configuration)
        } else {
            MockAIService(context)
        }
    }
    
    private val _databaseService: DatabaseServiceProtocol by lazy {
        AndroidDatabaseService(context)
    }
    
    private val _cacheService: CacheServiceProtocol by lazy {
        AndroidCacheService(context)
    }
    
    private val _nutritionService: NutritionServiceProtocol by lazy {
        AndroidNutritionService(
            aiService = _aiService,
            databaseService = _databaseService,
            cacheService = _cacheService,
            configuration = _configuration
        )
    }
    
    // MARK: - Public Service Access
    
    /**
     * AI-powered analysis service for text and images
     */
    val aiService: AIServiceProtocol get() = _aiService
    
    /**
     * Database service for persistent storage
     */
    val databaseService: DatabaseServiceProtocol get() = _databaseService
    
    /**
     * Cache service for temporary data storage
     */
    val cacheService: CacheServiceProtocol get() = _cacheService
    
    /**
     * Core nutrition analysis and food logging service
     */
    val nutritionService: NutritionServiceProtocol get() = _nutritionService
    
    /**
     * Application configuration service
     */
    val configuration: AppConfiguration get() = _configuration
    
    // MARK: - Service Management
    
    /**
     * Initialize all services and prepare for app startup
     */
    suspend fun startup() {
        try {
            // Initialize configuration
            if (_configuration.enableLogging) {
                _configuration.printConfigurationStatus()
                android.util.Log.d("ServiceContainer", "✅ Configuration service initialized")
            }
            
            // Validate services are ready
            val cacheSize = _cacheService.size().getOrDefault(0L)
            android.util.Log.d("ServiceContainer", "✅ Cache service initialized with size: $cacheSize bytes")
            
            // Check database connectivity
            val testData = _databaseService.fetchAll().getOrDefault(emptyList())
            android.util.Log.d("ServiceContainer", "✅ Database service initialized with ${testData.size} nutrition entries")
            
        } catch (e: Exception) {
            android.util.Log.w("ServiceContainer", "⚠️ Service startup warning: ${e.message}")
        }
    }
    
    /**
     * Cleanup resources when the app terminates
     */
    suspend fun shutdown() {
        try {
            // Clear temporary cache
            _cacheService.clear()
            android.util.Log.d("ServiceContainer", "✅ Services shutdown completed")
            
        } catch (e: Exception) {
            android.util.Log.e("ServiceContainer", "❌ Service shutdown error: ${e.message}")
        }
    }
    
    /**
     * Check service health status
     */
    suspend fun healthCheck(): Map<String, Boolean> {
        return mapOf(
            "ai_service" to try { _aiService.isProcessing; true } catch (e: Exception) { false },
            "database_service" to try { _databaseService.fetchAll(); true } catch (e: Exception) { false },
            "cache_service" to try { _cacheService.size(); true } catch (e: Exception) { false },
            "nutrition_service" to try { _nutritionService.serviceState; true } catch (e: Exception) { false },
            "configuration" to _configuration.hasAIConfiguration()
        )
    }
}

/**
 * Hilt Application for dependency injection setup
 */
@dagger.hilt.android.HiltAndroidApp
class MacroApplication : android.app.Application() {
    
    private val serviceContainer by lazy { ServiceContainer.getInstance(this) }
    
    override fun onCreate() {
        super.onCreate()
        
        // Initialize services
        kotlinx.coroutines.GlobalScope.launch {
            serviceContainer.startup()
        }
    }
    
    override fun onTerminate() {
        super.onTerminate()
        
        // Cleanup services
        kotlinx.coroutines.GlobalScope.launch {
            serviceContainer.shutdown()
        }
    }
}
