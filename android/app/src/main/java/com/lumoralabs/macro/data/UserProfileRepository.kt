package com.lumoralabs.macro.data

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.lumoralabs.macro.domain.UserProfile
import org.json.JSONObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

object UserProfileRepository {
    private const val PREFS_NAME = "user_profile"
    private const val PROFILE_KEY = "profile"
    private const val TAG = "UserProfileRepository"

    private fun getPrefs(context: Context): SharedPreferences = 
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    suspend fun saveProfile(context: Context, profile: UserProfile) {
        // Always save locally first for immediate access
        saveProfileLocally(context, profile)
        // Save to cloud if user is authenticated
        val currentUser = SupabaseService.Auth.getCurrentUser(context)
        if (currentUser != null) {
            // TODO: Fix this when we have proper user ID access
            // saveProfileToCloud(context, profile, currentUser.id)
        }
    }
    
    private fun saveProfileLocally(context: Context, profile: UserProfile) {
        val prefs = getPrefs(context)
        val obj = JSONObject().apply {
            put("firstName", profile.firstName)
            put("lastName", profile.lastName)
            put("age", profile.age)
            put("dob", profile.dob)
            put("height", profile.height)
            put("weight", profile.weight)
            put("gender", profile.gender)
            put("goal", profile.goal)
            put("activityLevel", profile.activityLevel)
            put("macroPreference", profile.macroPreference)
        }
        prefs.edit().putString(PROFILE_KEY, obj.toString()).apply()
    }
    
    private suspend fun saveProfileToCloud(context: Context, profile: UserProfile, userId: String) = withContext(Dispatchers.IO) {
        val data = mapOf(
            "id" to userId,
            "first_name" to profile.firstName,
            "last_name" to profile.lastName,
            "age" to profile.age,
            "dob" to profile.dob,
            "height" to profile.height,
            "weight" to profile.weight,
            "gender" to profile.gender,
            "goal" to profile.goal,
            "activity_level" to profile.activityLevel,
            "macro_preference" to profile.macroPreference,
            "last_updated" to System.currentTimeMillis()
        )
        
        try {
            // TODO: Implement Supabase client properly
            // val client = SupabaseService.getClient(context)
            // client.from("user_profiles").upsert(data)
            Log.d(TAG, "Profile would be saved to Supabase cloud when implemented")
        } catch (e: Exception) {
            Log.e(TAG, "Error saving profile to Supabase cloud", e)
        }
    }

    fun loadProfile(context: Context): UserProfile? {
        return loadProfileLocally(context)
    }

    private fun loadProfileLocally(context: Context): UserProfile? {
        val prefs = getPrefs(context)
        val profileStr = prefs.getString(PROFILE_KEY, null) ?: return null
        return try {
            val obj = JSONObject(profileStr)
            UserProfile(
                firstName = obj.optString("firstName", ""),
                lastName = obj.optString("lastName", ""),
                age = obj.optInt("age", 0),
                dob = obj.optString("dob", ""),
                height = obj.optDouble("height", 0.0).toFloat(),
                weight = obj.optDouble("weight", 0.0).toFloat(),
                gender = obj.optString("gender", ""),
                goal = obj.optString("goal", ""),
                activityLevel = obj.optString("activityLevel", ""),
                macroPreference = obj.optString("macroPreference", "")
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing profile", e)
            null
        }
    }

    suspend fun loadProfile(context: Context, onResult: (UserProfile?) -> Unit = {}) {
        // Try to load from cloud first if user is authenticated
        val currentUser = SupabaseService.Auth.getCurrentUser(context)
        if (currentUser != null) {
            // TODO: Implement cloud loading when we have proper user ID access
            // loadProfileFromCloud(context, currentUser.id) { cloudProfile ->
            //     if (cloudProfile != null) {
            //         saveProfileLocally(context, cloudProfile)
            //         onResult(cloudProfile)
            //     } else {
            //         onResult(loadProfileLocally(context))
            //     }
            // }
            onResult(loadProfileLocally(context))
        } else {
            // For unauthenticated users, only use local storage
            onResult(loadProfileLocally(context))
        }
    }
    
    private suspend fun loadProfileFromCloud(context: Context, userId: String, onResult: (UserProfile?) -> Unit) = withContext(Dispatchers.IO) {
        try {
            // TODO: Implement Supabase client properly
            // val client = SupabaseService.getClient(context)
            // val response = client.from("user_profiles").select().eq("id", userId).single()
            // val profile = response.decodeAs<UserProfile>()
            
            Log.d(TAG, "Loading profile from Supabase cloud (placeholder)")
            onResult(null) // Fallback to local for now
        } catch (e: Exception) {
            Log.e(TAG, "Error loading profile from Supabase cloud", e)
            onResult(null)
        }
    }
    
    /**
     * Migrates local profile data to cloud when user upgrades from anonymous to authenticated
     */
    suspend fun migrateLocalToCloud(context: Context) {
        val currentUser = SupabaseService.Auth.getCurrentUser(context)
        if (currentUser != null) {
            val localProfile = loadProfileLocally(context)
            if (localProfile != null) {
                // TODO: Implement when we have proper user ID access
                // saveProfileToCloud(context, localProfile, currentUser.id)
            }
        }
    }
    
    /**
     * Deletes local profile data (useful when user signs out)
     */
    fun clearLocalProfile(context: Context) {
        val prefs = getPrefs(context)
        prefs.edit().remove(PROFILE_KEY).apply()
    }
}
