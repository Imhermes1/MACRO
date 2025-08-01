package com.lumoralabs.macro.data.services

import com.lumoralabs.macro.data.configuration.AppConfiguration
import com.lumoralabs.macro.data.models.*
import com.lumoralabs.macro.data.services.implementation.*
import kotlinx.coroutines.test.runTest
import org.junit.Test
import org.junit.Assert.*
import org.junit.Before
import org.mockito.Mock
import org.mockito.MockitoAnnotations
import org.mockito.kotlin.whenever
import android.content.Context

/**
 * Unit tests for Android services
 * 
 * Tests the core functionality of AI, Database, Cache, and Nutrition services
 * using modern Android testing patterns
 */
class AndroidServicesTest {
    
    @Mock
    private lateinit var mockContext: Context
    
    @Mock
    private lateinit var mockConfiguration: AppConfiguration
    
    private lateinit var mockAIService: MockAIService
    private lateinit var androidDatabaseService: AndroidDatabaseService
    private lateinit var androidCacheService: AndroidCacheService
    private lateinit var androidNutritionService: AndroidNutritionService
    
    @Before
    fun setup() {
        MockitoAnnotations.openMocks(this)
        
        // Setup mock configuration
        whenever(mockConfiguration.hasAIConfiguration()).thenReturn(false)
        whenever(mockConfiguration.enableLogging).thenReturn(true)
        
        // Initialize services
        mockAIService = MockAIService(mockContext)
        androidCacheService = AndroidCacheService(mockContext)
        
        // Note: Database service requires actual Android context for Room
        // In real tests, use Robolectric or instrumented tests
    }
    
    @Test
    fun `MockAIService analyzes text correctly`() = runTest {
        // Given
        val testText = "chicken breast with rice"
        
        // When
        val result = mockAIService.analyzeText(testText, AnalysisContext.TEXT)
        
        // Then
        assertTrue("Analysis should succeed", result.isSuccess)
        
        val aiResult = result.getOrThrow()
        assertTrue("Should have content", aiResult.content.isNotEmpty())
        assertTrue("Should have reasonable confidence", aiResult.confidence > 0.5)
        assertEquals("Should be mock provider", "mock", aiResult.metadata["provider"])
    }
    
    @Test
    fun `MockAIService handles image analysis`() = runTest {
        // Given
        val testImageData = ByteArray(1024) { it.toByte() } // Mock image data
        val prompt = "Analyze this food image"
        
        // When
        val result = mockAIService.analyzeImage(testImageData, prompt)
        
        // Then
        assertTrue("Image analysis should succeed", result.isSuccess)
        
        val aiResult = result.getOrThrow()
        assertTrue("Should have content", aiResult.content.isNotEmpty())
        assertTrue("Should have lower confidence for images", aiResult.confidence >= 0.5)
        assertEquals("Should be mock provider", "mock", aiResult.metadata["provider"])
    }
    
    @Test
    fun `MockAIService generates conversational responses`() = runTest {
        // Given
        val prompt = "How many calories are in this food?"
        
        // When
        val result = mockAIService.generateResponse(prompt, AnalysisContext.TEXT)
        
        // Then
        assertTrue("Response generation should succeed", result.isSuccess)
        
        val response = result.getOrThrow()
        assertTrue("Should have response text", response.isNotEmpty())
        assertTrue("Should contain relevant content", 
            response.contains("calorie", ignoreCase = true) || 
            response.contains("nutrition", ignoreCase = true))
    }
    
    @Test
    fun `CacheService stores and retrieves data correctly`() = runTest {
        // Given
        val testKey = "test_nutrition_key"
        val testData = NutritionData(
            name = "Test Food",
            calories = 100.0,
            protein = 10.0,
            carbs = 15.0,
            fat = 5.0
        )
        
        // When - Store data
        val storeResult = androidCacheService.set(testKey, testData, 60000L) // 1 minute
        
        // Then - Verify storage
        assertTrue("Should store data successfully", storeResult.isSuccess)
        
        // When - Retrieve data
        val retrieveResult = androidCacheService.get(testKey, NutritionData::class.java)
        
        // Then - Verify retrieval
        assertTrue("Should retrieve data successfully", retrieveResult.isSuccess)
        val retrievedData = retrieveResult.getOrThrow()
        assertNotNull("Should have retrieved data", retrievedData)
        assertEquals("Should match stored data", testData.name, retrievedData?.name)
    }
    
    @Test
    fun `CacheService handles cache expiration`() = runTest {
        // Given
        val testKey = "expiring_key"
        val testData = "test_value"
        val shortExpiration = 1L // 1 millisecond
        
        // When - Store with short expiration
        val storeResult = androidCacheService.set(testKey, testData, shortExpiration)
        assertTrue("Should store data", storeResult.isSuccess)
        
        // Wait for expiration
        kotlinx.coroutines.delay(10L)
        
        // Then - Verify expiration
        val retrieveResult = androidCacheService.get(testKey, String::class.java)
        assertTrue("Should handle expiration gracefully", retrieveResult.isSuccess)
        assertNull("Should return null for expired data", retrieveResult.getOrThrow())
    }
    
    @Test
    fun `NutritionData model validates correctly`() {
        // Given valid nutrition data
        val validData = NutritionData(
            name = "Apple",
            calories = 95.0,
            protein = 0.5,
            carbs = 25.0,
            fat = 0.3,
            confidence = 0.9
        )
        
        // Then
        assertTrue("Valid data should pass validation", validData.isValid())
        
        // Given invalid nutrition data
        val invalidData = NutritionData(
            name = "",
            calories = -10.0,
            protein = -5.0,
            carbs = 20.0,
            fat = 2.0,
            confidence = 1.5 // Invalid confidence > 1.0
        )
        
        // Then
        assertFalse("Invalid data should fail validation", invalidData.isValid())
    }
    
    @Test
    fun `NutritionData calculates macro calories correctly`() {
        // Given
        val nutritionData = NutritionData(
            name = "Test Food",
            calories = 200.0,
            protein = 10.0, // 10g * 4 cal/g = 40 cal
            carbs = 20.0,   // 20g * 4 cal/g = 80 cal
            fat = 5.0,      // 5g * 9 cal/g = 45 cal
            confidence = 0.9
        )
        
        // When
        val macroCalories = nutritionData.macroCalories
        
        // Then
        val expectedMacroCalories = (10.0 * 4) + (20.0 * 4) + (5.0 * 9) // 165.0
        assertEquals("Should calculate macro calories correctly", 
            expectedMacroCalories, macroCalories, 0.01)
    }
    
    @Test
    fun `AIAnalysisResult parses nutrition data`() {
        // Given valid JSON content
        val validJsonContent = """
            {
                "id": "test-id",
                "name": "Test Food",
                "calories": 150.0,
                "protein": 8.0,
                "carbs": 20.0,
                "fat": 6.0,
                "confidence": 0.85,
                "source": "ai_analysis"
            }
        """.trimIndent()
        
        val aiResult = AIAnalysisResult(
            content = validJsonContent,
            confidence = 0.85
        )
        
        // When
        val nutritionData = aiResult.parseNutritionData()
        
        // Then
        assertNotNull("Should parse valid JSON", nutritionData)
        assertEquals("Should parse name correctly", "Test Food", nutritionData?.name)
        assertEquals("Should parse calories correctly", 150.0, nutritionData?.calories ?: 0.0, 0.01)
    }
    
    @Test
    fun `ServiceState provides correct status information`() {
        // Test different service states
        val idleState = ServiceState.Idle
        val loadingState = ServiceState.Loading
        val successState = ServiceState.Success("Operation completed")
        val errorState = ServiceState.Error(Exception("Test error"))
        
        // Verify state properties
        assertFalse("Idle should not be loading", idleState.isLoading)
        assertFalse("Idle should not be error", idleState.isError)
        assertFalse("Idle should not be success", idleState.isSuccess)
        
        assertTrue("Loading should be loading", loadingState.isLoading)
        assertFalse("Loading should not be error", loadingState.isError)
        
        assertTrue("Success should be success", successState.isSuccess)
        assertFalse("Success should not be error", successState.isError)
        
        assertTrue("Error should be error", errorState.isError)
        assertFalse("Error should not be success", errorState.isSuccess)
    }
    
    @Test
    fun `DatabaseResult provides proper error handling`() {
        // Given
        val successResult = DatabaseResult.Success("Test data")
        val errorResult = DatabaseResult.Error<String>(Exception("Database error"))
        
        // Test success operations
        var actionCalled = false
        successResult.onSuccess { actionCalled = true }
        assertTrue("Success action should be called", actionCalled)
        
        assertEquals("Should return success data", "Test data", successResult.getOrDefault("default"))
        assertEquals("Should return success data", "Test data", successResult.getOrNull())
        
        // Test error operations
        var errorActionCalled = false
        errorResult.onError { errorActionCalled = true }
        assertTrue("Error action should be called", errorActionCalled)
        
        assertEquals("Should return default on error", "default", errorResult.getOrDefault("default"))
        assertNull("Should return null on error", errorResult.getOrNull())
    }
}

/**
 * Integration tests for service interactions
 */
class ServiceIntegrationTest {
    
    @Mock
    private lateinit var mockContext: Context
    
    @Test
    fun `Services integrate correctly through dependency injection`() {
        // This test would verify that services work together correctly
        // In a real implementation, you would use Hilt testing utilities
        // or manual dependency injection for integration testing
        
        // Given
        val configuration = AppConfiguration.getInstance(mockContext)
        val aiService = MockAIService(mockContext)
        val cacheService = AndroidCacheService(mockContext)
        
        // When services are created with dependencies
        // Then they should initialize without errors
        assertNotNull("AI service should be created", aiService)
        assertNotNull("Cache service should be created", cacheService)
        assertNotNull("Configuration should be available", configuration)
    }
}

/**
 * Performance tests for service operations
 */
class ServicePerformanceTest {
    
    @Test
    fun `MockAIService responds within reasonable time`() = runTest {
        // Given
        val mockAIService = MockAIService(mockContext = org.mockito.Mockito.mock(Context::class.java))
        val startTime = System.currentTimeMillis()
        
        // When
        val result = mockAIService.analyzeText("test food", AnalysisContext.TEXT)
        val endTime = System.currentTimeMillis()
        
        // Then
        assertTrue("Analysis should succeed", result.isSuccess)
        val duration = endTime - startTime
        assertTrue("Should complete within 2 seconds", duration < 2000)
    }
    
    @Test
    fun `Cache operations perform efficiently`() = runTest {
        // Given
        val cacheService = AndroidCacheService(
            org.mockito.Mockito.mock(Context::class.java)
        )
        
        // When - Perform multiple cache operations
        val operations = 100
        val startTime = System.currentTimeMillis()
        
        repeat(operations) { i ->
            cacheService.set("key_$i", "value_$i", 60000L)
        }
        
        val endTime = System.currentTimeMillis()
        
        // Then
        val duration = endTime - startTime
        val avgTimePerOperation = duration.toDouble() / operations
        assertTrue("Average operation should be under 10ms", avgTimePerOperation < 10.0)
    }
}
