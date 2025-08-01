package com.lumoralabs.macro.data.services.implementation

import android.content.Context
import android.util.Log
import androidx.room.*
import com.lumoralabs.macro.data.models.*
import com.lumoralabs.macro.data.services.DatabaseServiceProtocol
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.serialization.encodeToString
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

/**
 * Room Database Entity for Nutrition Data
 */
@Entity(tableName = "nutrition_entries")
data class NutritionDataEntity(
    @PrimaryKey val id: String,
    val name: String,
    val brand: String?,
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val fiber: Double?,
    val sugar: Double?,
    val sodium: Double?,
    val confidence: Double,
    val source: String,
    val barcode: String?,
    val servingSize: String?,
    val servingUnit: String?,
    val timestamp: Long
) {
    fun toNutritionData(): NutritionData {
        return NutritionData(
            id = id,
            name = name,
            brand = brand,
            calories = calories,
            protein = protein,
            carbs = carbs,
            fat = fat,
            fiber = fiber,
            sugar = sugar,
            sodium = sodium,
            confidence = confidence,
            source = source,
            barcode = barcode,
            servingSize = servingSize,
            servingUnit = servingUnit,
            timestamp = timestamp
        )
    }
    
    companion object {
        fun fromNutritionData(data: NutritionData): NutritionDataEntity {
            return NutritionDataEntity(
                id = data.id,
                name = data.name,
                brand = data.brand,
                calories = data.calories,
                protein = data.protein,
                carbs = data.carbs,
                fat = data.fat,
                fiber = data.fiber,
                sugar = data.sugar,
                sodium = data.sodium,
                confidence = data.confidence,
                source = data.source,
                barcode = data.barcode,
                servingSize = data.servingSize,
                servingUnit = data.servingUnit,
                timestamp = data.timestamp
            )
        }
    }
}

/**
 * Room DAO for Nutrition Data
 */
@Dao
interface NutritionDao {
    
    @Query("SELECT * FROM nutrition_entries ORDER BY timestamp DESC")
    fun getAllNutritionData(): Flow<List<NutritionDataEntity>>
    
    @Query("SELECT * FROM nutrition_entries WHERE id = :id")
    suspend fun getNutritionById(id: String): NutritionDataEntity?
    
    @Query("SELECT * FROM nutrition_entries WHERE name LIKE '%' || :query || '%' OR brand LIKE '%' || :query || '%' ORDER BY timestamp DESC")
    suspend fun searchNutrition(query: String): List<NutritionDataEntity>
    
    @Query("SELECT * FROM nutrition_entries WHERE timestamp BETWEEN :startTime AND :endTime ORDER BY timestamp DESC")
    suspend fun getNutritionByDateRange(startTime: Long, endTime: Long): List<NutritionDataEntity>
    
    @Query("SELECT * FROM nutrition_entries WHERE barcode = :barcode LIMIT 1")
    suspend fun getNutritionByBarcode(barcode: String): NutritionDataEntity?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertNutrition(nutrition: NutritionDataEntity): Long
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAllNutrition(nutrition: List<NutritionDataEntity>): List<Long>
    
    @Update
    suspend fun updateNutrition(nutrition: NutritionDataEntity): Int
    
    @Delete
    suspend fun deleteNutrition(nutrition: NutritionDataEntity): Int
    
    @Query("DELETE FROM nutrition_entries WHERE id = :id")
    suspend fun deleteNutritionById(id: String): Int
    
    @Query("DELETE FROM nutrition_entries")
    suspend fun deleteAllNutrition(): Int
    
    @Query("SELECT COUNT(*) FROM nutrition_entries")
    suspend fun getNutritionCount(): Int
    
    @Query("SELECT SUM(calories) FROM nutrition_entries WHERE timestamp BETWEEN :startTime AND :endTime")
    suspend fun getTotalCaloriesInRange(startTime: Long, endTime: Long): Double?
}

/**
 * Room Database for MACRO app
 */
@Database(
    entities = [NutritionDataEntity::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(DatabaseConverters::class)
abstract class MacroDatabase : RoomDatabase() {
    abstract fun nutritionDao(): NutritionDao
    
    companion object {
        @Volatile
        private var INSTANCE: MacroDatabase? = null
        
        fun getDatabase(context: Context): MacroDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    MacroDatabase::class.java,
                    "macro_database"
                )
                    .fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}

/**
 * Type converters for Room database
 */
class DatabaseConverters {
    private val json = Json { ignoreUnknownKeys = true }
    
    @TypeConverter
    fun fromStringMap(value: Map<String, String>?): String {
        return if (value == null) "" else json.encodeToString(value)
    }
    
    @TypeConverter
    fun toStringMap(value: String): Map<String, String>? {
        return if (value.isEmpty()) null else {
            try {
                json.decodeFromString<Map<String, String>>(value)
            } catch (e: Exception) {
                null
            }
        }
    }
}

/**
 * Android Database Service Implementation using Room
 * 
 * Provides persistent storage for nutrition data with full CRUD operations
 * Built on modern Android architecture with Room database
 */
class AndroidDatabaseService(
    private val context: Context
) : DatabaseServiceProtocol {
    
    companion object {
        private const val TAG = "AndroidDatabaseService"
    }
    
    private val database: MacroDatabase by lazy {
        MacroDatabase.getDatabase(context)
    }
    
    private val nutritionDao: NutritionDao by lazy {
        database.nutritionDao()
    }
    
    init {
        Log.d(TAG, "AndroidDatabaseService initialized")
    }
    
    // MARK: - DatabaseServiceProtocol Implementation
    
    override suspend fun save(data: NutritionData): DatabaseResult<Unit> {
        return try {
            val entity = NutritionDataEntity.fromNutritionData(data)
            val result = nutritionDao.insertNutrition(entity)
            
            if (result > 0) {
                Log.d(TAG, "Saved nutrition data: ${data.name}")
                DatabaseResult.Success(Unit)
            } else {
                val error = Exception("Failed to insert nutrition data")
                Log.e(TAG, "Save failed for: ${data.name}", error)
                DatabaseResult.Error(error)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Database save error", e)
            DatabaseResult.Error(e)
        }
    }
    
    override suspend fun saveAll(data: List<NutritionData>): DatabaseResult<Unit> {
        return try {
            val entities = data.map { NutritionDataEntity.fromNutritionData(it) }
            val results = nutritionDao.insertAllNutrition(entities)
            
            if (results.all { it > 0 }) {
                Log.d(TAG, "Saved ${data.size} nutrition entries")
                DatabaseResult.Success(Unit)
            } else {
                val error = Exception("Failed to insert some nutrition data")
                Log.e(TAG, "Bulk save partially failed", error)
                DatabaseResult.Error(error)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Database bulk save error", e)
            DatabaseResult.Error(e)
        }
    }
    
    override suspend fun fetchAll(): DatabaseResult<List<NutritionData>> {
        return try {
            val entities = nutritionDao.getAllNutritionData().first()
            val nutritionData = entities.map { it.toNutritionData() }
            
            Log.d(TAG, "Fetched ${nutritionData.size} nutrition entries")
            DatabaseResult.Success(nutritionData)
        } catch (e: Exception) {
            Log.e(TAG, "Database fetch all error", e)
            DatabaseResult.Error(e)
        }
    }
    
    override suspend fun fetchById(id: String): DatabaseResult<NutritionData?> {
        return try {
            val entity = nutritionDao.getNutritionById(id)
            val nutritionData = entity?.toNutritionData()
            
            Log.d(TAG, "Fetched nutrition by ID: $id - ${if (nutritionData != null) "found" else "not found"}")
            DatabaseResult.Success(nutritionData)
        } catch (e: Exception) {
            Log.e(TAG, "Database fetch by ID error", e)
            DatabaseResult.Error(e)
        }
    }
    
    override suspend fun deleteById(id: String): DatabaseResult<Unit> {
        return try {
            val deletedCount = nutritionDao.deleteNutritionById(id)
            
            if (deletedCount > 0) {
                Log.d(TAG, "Deleted nutrition entry: $id")
                DatabaseResult.Success(Unit)
            } else {
                val error = Exception("Nutrition entry not found: $id")
                Log.w(TAG, "Delete failed - entry not found: $id")
                DatabaseResult.Error(error)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Database delete by ID error", e)
            DatabaseResult.Error(e)
        }
    }
    
    override suspend fun clear(): DatabaseResult<Unit> {
        return try {
            val deletedCount = nutritionDao.deleteAllNutrition()
            Log.d(TAG, "Cleared database - deleted $deletedCount entries")
            DatabaseResult.Success(Unit)
        } catch (e: Exception) {
            Log.e(TAG, "Database clear error", e)
            DatabaseResult.Error(e)
        }
    }
    
    override suspend fun search(query: String): DatabaseResult<List<NutritionData>> {
        return try {
            val entities = nutritionDao.searchNutrition(query)
            val nutritionData = entities.map { it.toNutritionData() }
            
            Log.d(TAG, "Search '$query' returned ${nutritionData.size} results")
            DatabaseResult.Success(nutritionData)
        } catch (e: Exception) {
            Log.e(TAG, "Database search error", e)
            DatabaseResult.Error(e)
        }
    }
    
    override suspend fun fetchByDateRange(startTime: Long, endTime: Long): DatabaseResult<List<NutritionData>> {
        return try {
            val entities = nutritionDao.getNutritionByDateRange(startTime, endTime)
            val nutritionData = entities.map { it.toNutritionData() }
            
            Log.d(TAG, "Date range query returned ${nutritionData.size} entries")
            DatabaseResult.Success(nutritionData)
        } catch (e: Exception) {
            Log.e(TAG, "Database date range query error", e)
            DatabaseResult.Error(e)
        }
    }
    
    // MARK: - Additional Database Operations
    
    /**
     * Get nutrition data by barcode
     */
    suspend fun fetchByBarcode(barcode: String): DatabaseResult<NutritionData?> {
        return try {
            val entity = nutritionDao.getNutritionByBarcode(barcode)
            val nutritionData = entity?.toNutritionData()
            
            Log.d(TAG, "Barcode lookup '$barcode': ${if (nutritionData != null) "found" else "not found"}")
            DatabaseResult.Success(nutritionData)
        } catch (e: Exception) {
            Log.e(TAG, "Database barcode lookup error", e)
            DatabaseResult.Error(e)
        }
    }
    
    /**
     * Update existing nutrition entry
     */
    suspend fun update(data: NutritionData): DatabaseResult<Unit> {
        return try {
            val entity = NutritionDataEntity.fromNutritionData(data)
            val updatedCount = nutritionDao.updateNutrition(entity)
            
            if (updatedCount > 0) {
                Log.d(TAG, "Updated nutrition data: ${data.name}")
                DatabaseResult.Success(Unit)
            } else {
                val error = Exception("Nutrition entry not found for update: ${data.id}")
                Log.w(TAG, "Update failed - entry not found: ${data.id}")
                DatabaseResult.Error(error)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Database update error", e)
            DatabaseResult.Error(e)
        }
    }
    
    /**
     * Get database statistics
     */
    suspend fun getStatistics(): DatabaseResult<DatabaseStats> {
        return try {
            val totalEntries = nutritionDao.getNutritionCount()
            val now = System.currentTimeMillis()
            val oneDayAgo = now - (24 * 60 * 60 * 1000)
            val oneWeekAgo = now - (7 * 24 * 60 * 60 * 1000)
            
            val todayCalories = nutritionDao.getTotalCaloriesInRange(oneDayAgo, now) ?: 0.0
            val weekCalories = nutritionDao.getTotalCaloriesInRange(oneWeekAgo, now) ?: 0.0
            
            val stats = DatabaseStats(
                totalEntries = totalEntries,
                todayCalories = todayCalories,
                weekCalories = weekCalories
            )
            
            Log.d(TAG, "Database stats: $stats")
            DatabaseResult.Success(stats)
        } catch (e: Exception) {
            Log.e(TAG, "Database statistics error", e)
            DatabaseResult.Error(e)
        }
    }
    
    /**
     * Get live flow of all nutrition data for UI observation
     */
    fun getNutritionFlow(): Flow<List<NutritionData>> {
        return kotlinx.coroutines.flow.map(nutritionDao.getAllNutritionData()) { entities ->
            entities.map { it.toNutritionData() }
        }
    }
}

/**
 * Database statistics data class
 */
data class DatabaseStats(
    val totalEntries: Int,
    val todayCalories: Double,
    val weekCalories: Double
)
