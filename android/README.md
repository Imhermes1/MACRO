# MACRO Android Services Architecture

## 📱 Android Services Implementation

This directory contains the complete Android services implementation for the MACRO nutrition tracking app, built with modern Android architecture patterns.

## 🏗️ Architecture Overview

### Service Layer Structure
```
android/app/src/main/java/com/lumoralabs/macro/data/
├── models/                     # Data models and entities
│   └── NutritionModels.kt     # Core nutrition data classes
├── services/                   # Service interfaces and protocols
│   └── ServiceProtocols.kt    # Service contracts and interfaces
├── services/implementation/    # Concrete service implementations
│   ├── ProductionAIService.kt # Real AI service with OpenAI/Anthropic
│   ├── MockAIService.kt       # Development mock AI service
│   ├── AndroidDatabaseService.kt # Room database implementation
│   ├── AndroidCacheService.kt  # Cache service with SharedPrefs + FileSystem
│   └── AndroidNutritionService.kt # Comprehensive nutrition service
├── configuration/              # Secure configuration management
│   └── AppConfiguration.kt    # API keys and app configuration
└── di/                        # Dependency injection
    └── ServiceContainer.kt    # Hilt modules and service container
```

## 🔧 Services Overview

### 1. **AI Service** (`AIServiceProtocol`)
Provides intelligent nutrition analysis using AI APIs.

**Implementations:**
- **ProductionAIService**: Real OpenAI/Anthropic integration
- **MockAIService**: Development mock with realistic responses

**Features:**
- Text analysis for food descriptions
- Image analysis for food photos
- Conversational AI responses
- Fallback mechanisms
- Error handling and retry logic

```kotlin
// Usage example
val result = aiService.analyzeText("chicken breast with rice", AnalysisContext.TEXT)
result.onSuccess { aiResult ->
    val nutritionData = aiResult.parseNutritionData()
}
```

### 2. **Database Service** (`DatabaseServiceProtocol`)
Persistent storage using Room database.

**Features:**
- Full CRUD operations for nutrition data
- Date range queries
- Text search functionality
- Barcode lookup
- Data validation and constraints
- Migration support

```kotlin
// Usage example
val nutritionData = NutritionData(name = "Apple", calories = 95.0, ...)
val result = databaseService.save(nutritionData)
```

### 3. **Cache Service** (`CacheServiceProtocol`)
High-performance caching with automatic expiration.

**Features:**
- Multi-tier caching (memory + SharedPrefs + file system)
- Automatic expiration management
- Size-based eviction
- Background cleanup
- Performance optimization

```kotlin
// Usage example
cacheService.set("nutrition_key", nutritionData, expirationMs = 3600000L)
val cached = cacheService.get("nutrition_key", NutritionData::class.java)
```

### 4. **Nutrition Service** (`NutritionServiceProtocol`)
Comprehensive nutrition analysis orchestrating all other services.

**Features:**
- Multi-modal food analysis (text, image, barcode, recipe)
- Intelligent caching and database integration
- Nutrition history and summaries
- Real-time data streams for UI
- Service health monitoring

```kotlin
// Usage example
val result = nutritionService.analyzeTextInput("grilled salmon")
result.onSuccess { nutritionData ->
    // Data automatically cached and saved to database
}
```

### 5. **Configuration Service** (`ConfigurationServiceProtocol`)
Secure API key and configuration management.

**Features:**
- Encrypted storage with Android Keystore
- Multiple configuration sources (env vars, encrypted prefs, BuildConfig)
- Runtime validation
- Development helpers

## 🔐 Security Features

### API Key Management
1. **Development**: Environment variables or BuildConfig
2. **Production**: Encrypted SharedPreferences with Android Keystore
3. **Fallback**: BuildConfig values (never hardcoded)

### Security Measures
- ✅ No hardcoded API keys in source code
- ✅ Android Keystore encryption for sensitive data
- ✅ Secure HTTP client configuration
- ✅ Runtime configuration validation
- ✅ Automatic key rotation support

## 🚀 Getting Started

### 1. Dependencies
The services use modern Android libraries:

```kotlin
// Key dependencies (already configured in build.gradle.kts)
implementation "com.google.dagger:hilt-android:2.51.1"
implementation "com.squareup.okhttp3:okhttp:4.12.0"
implementation "androidx.room:room-runtime:2.6.1"
implementation "androidx.security:security-crypto:1.1.0-alpha06"
implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3"
```

### 2. Configuration Setup
Configure your API keys securely:

**Option A: Environment Variables (Development)**
```bash
export OPENAI_API_KEY="sk-your-openai-key"
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"
```

**Option B: Encrypted Storage (Production)**
```kotlin
val config = AppConfiguration.getInstance(context)
config.setSecureValue("OPENAI_API_KEY", "your-key")
config.setSecureValue("ANTHROPIC_API_KEY", "your-key")
```

**Option C: BuildConfig (Fallback)**
```kotlin
// In app/build.gradle.kts
android {
    defaultConfig {
        buildConfigField("String", "OPENAI_API_KEY", "\"${project.findProperty("OPENAI_API_KEY") ?: ""}\"")
    }
}
```

### 3. Service Integration

**With Hilt Dependency Injection:**
```kotlin
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    
    @Inject
    lateinit var nutritionService: NutritionServiceProtocol
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Services are automatically injected and ready to use
        lifecycleScope.launch {
            val result = nutritionService.analyzeTextInput("banana")
        }
    }
}
```

**Manual Service Container:**
```kotlin
class MyActivity : AppCompatActivity() {
    private val serviceContainer by lazy { ServiceContainer.getInstance(this) }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        lifecycleScope.launch {
            val result = serviceContainer.nutritionService.analyzeTextInput("apple")
        }
    }
}
```

### 4. Compose Integration
```kotlin
@Composable
fun NutritionAnalysisScreen(
    nutritionService: NutritionServiceProtocol = hiltViewModel()
) {
    val serviceState by nutritionService.serviceState.collectAsState()
    
    when (serviceState) {
        is ServiceState.Loading -> CircularProgressIndicator()
        is ServiceState.Success -> Text("Analysis completed!")
        is ServiceState.Error -> Text("Error: ${serviceState.exception.message}")
        else -> { /* Idle state */ }
    }
}
```

## 🧪 Testing

### Unit Tests
Comprehensive unit tests are provided in `AndroidServicesTest.kt`:

```bash
# Run unit tests
./gradlew testDebugUnitTest

# Run specific test class
./gradlew testDebugUnitTest --tests="AndroidServicesTest"
```

### Test Coverage
- ✅ Service functionality testing
- ✅ Data model validation
- ✅ Cache operations and expiration
- ✅ Error handling scenarios
- ✅ Performance benchmarks

### Integration Testing
```kotlin
@Test
fun `services integrate correctly through dependency injection`() {
    // Test service interactions and dependency resolution
}
```

## 📊 Performance Characteristics

### AI Service Performance
- **Text Analysis**: ~500ms (mock) / 1-3s (production)
- **Image Analysis**: ~1.2s (mock) / 3-8s (production)
- **Response Generation**: ~300ms (mock) / 1-2s (production)

### Cache Performance
- **Memory Cache**: ~1ms access time
- **SharedPrefs Cache**: ~5ms access time
- **File System Cache**: ~10-20ms access time
- **Automatic Cleanup**: Every 1 hour

### Database Performance
- **Simple Queries**: ~5-10ms
- **Search Operations**: ~20-50ms
- **Bulk Operations**: ~100ms for 1000 records

## 🔧 Configuration Options

### Cache Configuration
```kotlin
val cacheService = AndroidCacheService(
    context = context,
    maxCacheSizeMB = 100L // Configurable cache size
)
```

### AI Service Configuration
```kotlin
// Automatic service selection based on available API keys
val aiService = if (config.hasAIConfiguration()) {
    ProductionAIService(context, config)
} else {
    MockAIService(context) // For development
}
```

## 🚦 Service Health Monitoring

### Health Check
```kotlin
val healthStatus = serviceContainer.healthCheck()
// Returns Map<String, Boolean> with service status
```

### Real-time Status
```kotlin
nutritionService.getServiceStatus().collect { status ->
    when {
        status.isHealthy -> showHealthyState()
        status.lastError != null -> showErrorState(status.lastError)
        status.aiServiceProcessing -> showLoadingState()
    }
}
```

## 🐛 Troubleshooting

### Common Issues

**1. No AI Configuration Error**
```
Solution: Configure API keys using AppConfiguration.setSecureValue()
or set environment variables
```

**2. Database Migration Issues**
```
Solution: Room will fallback to destructive migration in debug builds
For production, implement proper migration strategies
```

**3. Cache Storage Issues**
```
Solution: Check device storage permissions and available space
Cache automatically manages size constraints
```

**4. Network Connectivity**
```
Solution: Services include automatic retry logic and fallback mechanisms
Check network permissions and API key validity
```

### Debug Logging
Enable debug logging in development:
```kotlin
AppConfiguration.getInstance(context).printConfigurationStatus()
```

## 📚 API Documentation

Detailed API documentation is available in the service interface files:
- `ServiceProtocols.kt` - Complete interface documentation
- Individual implementation files contain usage examples
- Unit tests demonstrate proper usage patterns

## 🔄 Migration from iOS

The Android services mirror the iOS implementation:
- Same service interfaces and contracts
- Equivalent functionality and features
- Consistent data models and validation
- Similar performance characteristics
- Cross-platform API compatibility

This ensures consistent behavior across iOS and Android platforms while leveraging platform-specific optimizations.

---

For complete setup instructions, see the main [API_SETUP.md](../../API_SETUP.md) documentation.
