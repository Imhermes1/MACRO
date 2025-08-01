package com.lumoralabs.macro.data.services.implementation

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.lumoralabs.macro.data.models.CacheEntry
import com.lumoralabs.macro.data.services.CacheServiceProtocol
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.serialization.encodeToString
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import java.io.File
import java.util.concurrent.ConcurrentHashMap

/**
 * Android Cache Service Implementation
 * 
 * Provides fast, persistent caching using SharedPreferences and file system
 * with automatic expiration and size management
 */
class AndroidCacheService(
    private val context: Context,
    private val maxCacheSizeMB: Long = 100L
) : CacheServiceProtocol {
    
    companion object {
        private const val TAG = "AndroidCacheService"
        private const val CACHE_PREFS_NAME = "macro_cache_prefs"
        private const val CACHE_DIR_NAME = "macro_cache"
        private const val METADATA_SUFFIX = "_meta"
        private const val CLEANUP_INTERVAL_MS = 60 * 60 * 1000L // 1 hour
    }
    
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }
    
    private val sharedPrefs: SharedPreferences by lazy {
        context.getSharedPreferences(CACHE_PREFS_NAME, Context.MODE_PRIVATE)
    }
    
    private val cacheDir: File by lazy {
        File(context.cacheDir, CACHE_DIR_NAME).apply {
            if (!exists()) mkdirs()
        }
    }
    
    // In-memory cache for frequently accessed items
    private val memoryCache = ConcurrentHashMap<String, Any>()
    private val cacheMutex = Mutex()
    private var lastCleanupTime = 0L
    
    init {
        Log.d(TAG, "AndroidCacheService initialized with max size: ${maxCacheSizeMB}MB")
        
        // Perform initial cleanup if needed
        kotlinx.coroutines.GlobalScope.launch {
            performMaintenanceIfNeeded()
        }
    }
    
    // MARK: - CacheServiceProtocol Implementation
    
    override suspend fun <T> set(key: String, value: T, expirationMs: Long): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                cacheMutex.withLock {
                    val expirationTime = System.currentTimeMillis() + expirationMs
                    val cacheEntry = CacheEntry(
                        key = key,
                        value = value,
                        expirationTime = expirationTime
                    )
                    
                    // Store in memory cache for fast access
                    memoryCache[key] = value
                    
                    // Determine storage method based on value size
                    val serializedValue = json.encodeToString(cacheEntry)
                    
                    if (serializedValue.length < 1024) {
                        // Small values go to SharedPreferences
                        storeInSharedPrefs(key, serializedValue)
                    } else {
                        // Large values go to file system
                        storeInFileSystem(key, serializedValue)
                    }
                    
                    // Store metadata
                    storeMetadata(key, cacheEntry.expirationTime, serializedValue.length.toLong())
                    
                    Log.d(TAG, "Cached key '$key' (${serializedValue.length} bytes)")
                    performMaintenanceIfNeeded()
                }
                
                Result.success(Unit)
            } catch (e: Exception) {
                Log.e(TAG, "Cache set error for key '$key'", e)
                Result.failure(e)
            }
        }
    }
    
    override suspend fun <T> get(key: String, type: Class<T>): Result<T?> {
        return withContext(Dispatchers.IO) {
            try {
                cacheMutex.withLock {
                    // Check memory cache first
                    @Suppress("UNCHECKED_CAST")
                    memoryCache[key]?.let { value ->
                        if (type.isInstance(value)) {
                            Log.d(TAG, "Cache hit (memory) for key '$key'")
                            return@withContext Result.success(value as T)
                        }
                    }
                    
                    // Check if key has expired metadata
                    if (isExpired(key)) {
                        Log.d(TAG, "Cache miss (expired) for key '$key'")
                        remove(key) // Clean up expired entry
                        return@withContext Result.success(null)
                    }
                    
                    // Try to load from storage
                    val serializedValue = loadFromStorage(key)
                    if (serializedValue != null) {
                        val cacheEntry = json.decodeFromString<CacheEntry<T>>(serializedValue)
                        
                        if (cacheEntry.isExpired()) {
                            Log.d(TAG, "Cache miss (expired during load) for key '$key'")
                            remove(key)
                            return@withContext Result.success(null)
                        }
                        
                        // Store in memory cache for future access
                        memoryCache[key] = cacheEntry.value as Any
                        
                        Log.d(TAG, "Cache hit (storage) for key '$key'")
                        Result.success(cacheEntry.value)
                    } else {
                        Log.d(TAG, "Cache miss for key '$key'")
                        Result.success(null)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Cache get error for key '$key'", e)
                Result.failure(e)
            }
        }
    }
    
    override suspend fun remove(key: String): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                cacheMutex.withLock {
                    // Remove from memory cache
                    memoryCache.remove(key)
                    
                    // Remove from SharedPreferences
                    sharedPrefs.edit().remove(key).apply()
                    
                    // Remove from file system
                    val file = File(cacheDir, key)
                    if (file.exists()) {
                        file.delete()
                    }
                    
                    // Remove metadata
                    sharedPrefs.edit().remove(key + METADATA_SUFFIX).apply()
                    
                    Log.d(TAG, "Removed cache entry for key '$key'")
                }
                
                Result.success(Unit)
            } catch (e: Exception) {
                Log.e(TAG, "Cache remove error for key '$key'", e)
                Result.failure(e)
            }
        }
    }
    
    override suspend fun clear(): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                cacheMutex.withLock {
                    // Clear memory cache
                    memoryCache.clear()
                    
                    // Clear SharedPreferences
                    sharedPrefs.edit().clear().apply()
                    
                    // Clear file system cache
                    cacheDir.listFiles()?.forEach { file ->
                        file.delete()
                    }
                    
                    Log.d(TAG, "Cleared all cache entries")
                }
                
                Result.success(Unit)
            } catch (e: Exception) {
                Log.e(TAG, "Cache clear error", e)
                Result.failure(e)
            }
        }
    }
    
    override suspend fun size(): Result<Long> {
        return withContext(Dispatchers.IO) {
            try {
                cacheMutex.withLock {
                    var totalSize = 0L
                    
                    // Calculate SharedPreferences size (approximate)
                    val prefsSize = sharedPrefs.all.values.sumOf { value ->
                        value.toString().length.toLong()
                    }
                    totalSize += prefsSize
                    
                    // Calculate file system cache size
                    val fileSize = cacheDir.listFiles()?.sumOf { file ->
                        file.length()
                    } ?: 0L
                    totalSize += fileSize
                    
                    Log.d(TAG, "Total cache size: $totalSize bytes")
                    Result.success(totalSize)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Cache size calculation error", e)
                Result.failure(e)
            }
        }
    }
    
    override suspend fun contains(key: String): Result<Boolean> {
        return withContext(Dispatchers.IO) {
            try {
                cacheMutex.withLock {
                    val exists = memoryCache.containsKey(key) ||
                            sharedPrefs.contains(key) ||
                            File(cacheDir, key).exists()
                    
                    // Check if entry is expired
                    if (exists && isExpired(key)) {
                        remove(key)
                        Result.success(false)
                    } else {
                        Result.success(exists)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Cache contains check error for key '$key'", e)
                Result.failure(e)
            }
        }
    }
    
    // MARK: - Storage Implementation
    
    private fun storeInSharedPrefs(key: String, value: String) {
        sharedPrefs.edit().putString(key, value).apply()
    }
    
    private fun storeInFileSystem(key: String, value: String) {
        val file = File(cacheDir, key)
        file.writeText(value)
    }
    
    private fun loadFromStorage(key: String): String? {
        // Try SharedPreferences first
        sharedPrefs.getString(key, null)?.let { return it }
        
        // Try file system
        val file = File(cacheDir, key)
        return if (file.exists()) {
            try {
                file.readText()
            } catch (e: Exception) {
                Log.e(TAG, "Error reading cache file for key '$key'", e)
                null
            }
        } else {
            null
        }
    }
    
    // MARK: - Metadata Management
    
    private fun storeMetadata(key: String, expirationTime: Long, sizeBytes: Long) {
        val metadata = "$expirationTime,$sizeBytes"
        sharedPrefs.edit().putString(key + METADATA_SUFFIX, metadata).apply()
    }
    
    private fun getMetadata(key: String): Pair<Long, Long>? {
        val metadataString = sharedPrefs.getString(key + METADATA_SUFFIX, null)
        return metadataString?.split(",")?.let { parts ->
            if (parts.size == 2) {
                try {
                    Pair(parts[0].toLong(), parts[1].toLong())
                } catch (e: NumberFormatException) {
                    null
                }
            } else {
                null
            }
        }
    }
    
    private fun isExpired(key: String): Boolean {
        val metadata = getMetadata(key) ?: return false
        val expirationTime = metadata.first
        return System.currentTimeMillis() > expirationTime
    }
    
    // MARK: - Cache Maintenance
    
    private suspend fun performMaintenanceIfNeeded() {
        val now = System.currentTimeMillis()
        if (now - lastCleanupTime > CLEANUP_INTERVAL_MS) {
            lastCleanupTime = now
            performMaintenance()
        }
    }
    
    private suspend fun performMaintenance() {
        withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "Performing cache maintenance")
                
                // Remove expired entries
                removeExpiredEntries()
                
                // Check cache size and remove oldest entries if needed
                val currentSize = size().getOrDefault(0L)
                val maxSizeBytes = maxCacheSizeMB * 1024 * 1024
                
                if (currentSize > maxSizeBytes) {
                    Log.d(TAG, "Cache size ($currentSize bytes) exceeds limit ($maxSizeBytes bytes)")
                    removeOldestEntries(currentSize - maxSizeBytes)
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Cache maintenance error", e)
            }
        }
    }
    
    private suspend fun removeExpiredEntries() {
        cacheMutex.withLock {
            val allKeys = mutableSetOf<String>()
            
            // Collect all keys from SharedPreferences
            allKeys.addAll(sharedPrefs.all.keys.filter { !it.endsWith(METADATA_SUFFIX) })
            
            // Collect all keys from file system
            cacheDir.listFiles()?.forEach { file ->
                allKeys.add(file.name)
            }
            
            // Remove expired entries
            var expiredCount = 0
            allKeys.forEach { key ->
                if (isExpired(key)) {
                    remove(key)
                    expiredCount++
                }
            }
            
            if (expiredCount > 0) {
                Log.d(TAG, "Removed $expiredCount expired cache entries")
            }
        }
    }
    
    private suspend fun removeOldestEntries(bytesToRemove: Long) {
        cacheMutex.withLock {
            val entries = mutableListOf<Pair<String, Long>>()
            
            // Collect all entries with their timestamps
            sharedPrefs.all.keys.filter { !it.endsWith(METADATA_SUFFIX) }.forEach { key ->
                val metadata = getMetadata(key)
                if (metadata != null) {
                    entries.add(Pair(key, metadata.first))
                }
            }
            
            cacheDir.listFiles()?.forEach { file ->
                val metadata = getMetadata(file.name)
                if (metadata != null) {
                    entries.add(Pair(file.name, metadata.first))
                }
            }
            
            // Sort by expiration time (oldest first)
            entries.sortBy { it.second }
            
            // Remove oldest entries until we free enough space
            var freedBytes = 0L
            var removedCount = 0
            
            for ((key, _) in entries) {
                if (freedBytes >= bytesToRemove) break
                
                val metadata = getMetadata(key)
                if (metadata != null) {
                    freedBytes += metadata.second
                    remove(key)
                    removedCount++
                }
            }
            
            Log.d(TAG, "Removed $removedCount old cache entries to free $freedBytes bytes")
        }
    }
    
    // MARK: - Cache Statistics
    
    /**
     * Get cache statistics for monitoring
     */
    suspend fun getStatistics(): Result<CacheStatistics> {
        return withContext(Dispatchers.IO) {
            try {
                cacheMutex.withLock {
                    val totalSize = size().getOrDefault(0L)
                    val memoryEntries = memoryCache.size
                    val prefsEntries = sharedPrefs.all.keys.count { !it.endsWith(METADATA_SUFFIX) }
                    val fileEntries = cacheDir.listFiles()?.size ?: 0
                    
                    val stats = CacheStatistics(
                        totalSizeBytes = totalSize,
                        memoryEntries = memoryEntries,
                        persistentEntries = prefsEntries + fileEntries,
                        maxSizeBytes = maxCacheSizeMB * 1024 * 1024
                    )
                    
                    Result.success(stats)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Cache statistics error", e)
                Result.failure(e)
            }
        }
    }
}

/**
 * Cache statistics data class
 */
data class CacheStatistics(
    val totalSizeBytes: Long,
    val memoryEntries: Int,
    val persistentEntries: Int,
    val maxSizeBytes: Long
) {
    val usagePercentage: Double
        get() = if (maxSizeBytes > 0) (totalSizeBytes.toDouble() / maxSizeBytes) * 100 else 0.0
    
    val totalEntries: Int
        get() = memoryEntries + persistentEntries
}
