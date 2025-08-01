package com.lumoralabs.macro.data

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.lumoralabs.macro.domain.UserProfile
import org.json.JSONObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class UserProfileRepository(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    companion object {
        private const val PREFS_NAME = "user_profile"
        private const val PROFILE_KEY = "profile"
        private const val TAG = "UserProfileRepository"
    }

    suspend fun saveProfile(profile: UserProfile) {
        // Always save locally first for immediate access
        saveProfileLocally(profile)
        
        // Save to cloud if user is authenticated
        val currentUser = SupabaseService.Auth.getCurrentUser()
        if (currentUser != null) {
            saveProfileToCloud(profile, currentUser.id)
        }
    }
    
    private fun saveProfileLocally(profile: UserProfile) {
        val obj = JSONObject().apply {
            put("firstName", profile.firstName)
            put("lastName", profile.lastName)
            put("age", profile.age)
            put("dob", profile.dob)
            put("height", profile.height)
            put("weight", profile.weight)
        }
        prefs.edit().putString(PROFILE_KEY, obj.toString()).apply()
    }
    
    private suspend fun saveProfileToCloud(profile: UserProfile, userId: String) = withContext(Dispatchers.IO) {
        val data = mapOf(
            "id" to userId,
            "firstName" to profile.firstName,
            "lastName" to profile.lastName,
            "age" to profile.age,
            "dob" to profile.dob,
            "height" to profile.height,
            "weight" to profile.weight,
            "lastUpdated" to System.currentTimeMillis()
        )
        
        try {
            // TODO: Replace with actual Supabase client implementation
            // This is a placeholder - implement using Supabase Kotlin client
            // Documentation: https://supabase.com/docs/reference/kotlin/insert
            
            // Example implementation would be:
            // supabase.from("user_profiles").upsert(data)
            
            Log.d(TAG, "Profile saved to Supabase cloud (placeholder)")
        } catch (e: Exception) {
            Log.e(TAG, "Error saving profile to Supabase cloud", e)
        }
    }

    suspend fun loadProfile(onResult: (UserProfile?) -> Unit = {}) {
        // Try to load from cloud first if user is authenticated
        val currentUser = SupabaseService.Auth.getCurrentUser()
        if (currentUser != null) {
            loadProfileFromCloud(currentUser.id) { cloudProfile ->
                if (cloudProfile != null) {
                    // Save cloud data locally for offline access
                    saveProfileLocally(cloudProfile)
                    onResult(cloudProfile)
                } else {
                    // Fallback to local data
                    onResult(loadProfileLocally())
                }
            }
        } else {
            // For unauthenticated users, only use local storage
            onResult(loadProfileLocally())
        }
    }
    
    private fun loadProfileLocally(): UserProfile? {
        val json = prefs.getString(PROFILE_KEY, null) ?: return null
        return try {
            val obj = JSONObject(json)
            UserProfile(
                firstName = obj.getString("firstName"),
                lastName = obj.optString("lastName", null),
                age = obj.getInt("age"),
                dob = obj.optString("dob", null),
                height = obj.getDouble("height").toFloat(),
                weight = obj.getDouble("weight").toFloat()
            )
        } catch (e: Exception) {
            // Error parsing local profile data
            null
        }
    }
    
    private suspend fun loadProfileFromCloud(userId: String, onResult: (UserProfile?) -> Unit) = withContext(Dispatchers.IO) {
        try {
            // TODO: Replace with actual Supabase client implementation
            // This is a placeholder - implement using Supabase Kotlin client
            // Documentation: https://supabase.com/docs/reference/kotlin/select
            
            // Example implementation would be:
            // val response = supabase.from("user_profiles").select().eq("id", userId).single()
            // val profile = response.decodeAs<UserProfile>()
            
            Log.d(TAG, "Loading profile from Supabase cloud (placeholder)")
            onResult(null) // Fallback to local for now
        } catch (e: Exception) {
            Log.e(TAG, "Error loading profile from Supabase cloud", e)
            onResult(null)
        }
    }
    
    // Synchronous version for backward compatibility
    fun loadProfile(): UserProfile? {
        return loadProfileLocally()
    }
    
    /**
     * Migrates local profile data to cloud when user upgrades from anonymous to authenticated
     */
    suspend fun migrateLocalToCloud() {
        val currentUser = SupabaseService.Auth.getCurrentUser()
        if (currentUser != null) {
            val localProfile = loadProfileLocally()
            if (localProfile != null) {
                saveProfileToCloud(localProfile, currentUser.id)
            }
        }
    }
    
    /**
     * Deletes local profile data (useful when user signs out)
     */
    fun clearLocalProfile() {
        prefs.edit().remove(PROFILE_KEY).apply()
    }
}
