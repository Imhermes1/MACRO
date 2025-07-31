package com.lumoralabs.macro.data

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FieldValue
import com.lumoralabs.macro.domain.UserProfile
import org.json.JSONObject

class UserProfileRepository(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val db = FirebaseFirestore.getInstance()
    private val auth = FirebaseAuth.getInstance()

    companion object {
        private const val PREFS_NAME = "user_profile"
        private const val PROFILE_KEY = "profile"
        private const val TAG = "UserProfileRepository"
    }

    fun saveProfile(profile: UserProfile) {
        // Always save locally first for immediate access
        saveProfileLocally(profile)
        
        // Save to cloud if user is authenticated (not anonymous)
        val currentUser = auth.currentUser
        if (currentUser != null && !currentUser.isAnonymous) {
            saveProfileToCloud(profile, currentUser.uid)
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
    
    private fun saveProfileToCloud(profile: UserProfile, userId: String) {
        val data = hashMapOf(
            "firstName" to profile.firstName,
            "lastName" to profile.lastName,
            "age" to profile.age,
            "dob" to profile.dob,
            "height" to profile.height,
            "weight" to profile.weight,
            "lastUpdated" to FieldValue.serverTimestamp()
        )
        
        db.collection("userProfiles").document(userId)
            .set(data)
            .addOnSuccessListener {
                // Profile successfully saved to cloud
            }
            .addOnFailureListener { e ->
                // Error saving profile to cloud
            }
    }

    fun loadProfile(onResult: (UserProfile?) -> Unit = {}) {
        // Try to load from cloud first if user is authenticated
        val currentUser = auth.currentUser
        if (currentUser != null && !currentUser.isAnonymous) {
            loadProfileFromCloud(currentUser.uid) { cloudProfile ->
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
            // For anonymous users, only use local storage
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
    
    private fun loadProfileFromCloud(userId: String, onResult: (UserProfile?) -> Unit) {
        db.collection("userProfiles").document(userId)
            .get()
            .addOnSuccessListener { document ->
                if (document.exists()) {
                    try {
                        val data = document.data!!
                        val profile = UserProfile(
                            firstName = data["firstName"] as String,
                            lastName = data["lastName"] as? String,
                            age = (data["age"] as Long).toInt(),
                            dob = data["dob"] as? String,
                            height = (data["height"] as Double).toFloat(),
                            weight = (data["weight"] as Double).toFloat()
                        )
                        onResult(profile)
                    } catch (e: Exception) {
                        // Error parsing cloud profile data
                        onResult(null)
                    }
                } else {
                    // No cloud profile found
                    onResult(null)
                }
            }
            .addOnFailureListener { e ->
                // Error loading profile from cloud
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
    fun migrateLocalToCloud() {
        val currentUser = auth.currentUser
        if (currentUser != null && !currentUser.isAnonymous) {
            val localProfile = loadProfileLocally()
            if (localProfile != null) {
                saveProfileToCloud(localProfile, currentUser.uid)
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
