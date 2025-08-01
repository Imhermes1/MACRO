package com.lumoralabs.macro.presentation.authentication

import android.content.Context
import android.content.SharedPreferences
import com.lumoralabs.macro.data.UserProfileRepository
import com.lumoralabs.macro.data.SupabaseService

/**
 * SessionManager handles user session state and app flow logic.
 * Equivalent to iOS SessionStore for managing authentication and onboarding flow.
 * 
 * Updated to use Supabase Authentication:
 * https://supabase.com/docs/guides/auth
 */
class SessionManager private constructor(context: Context) {
    
    companion object {
        @Volatile
        private var INSTANCE: SessionManager? = null
        
        fun getInstance(context: Context): SessionManager {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: SessionManager(context.applicationContext).also { INSTANCE = it }
            }
        }
        
        // SharedPreferences keys
        private const val PREFS_NAME = "macro_session_prefs"
        private const val KEY_WELCOME_SCREEN_SEEN = "welcome_screen_seen"
        private const val KEY_BMI_CALCULATOR_COMPLETED = "bmi_calculator_completed"
        private const val KEY_ONBOARDING_DEMO_SHOWN = "onboarding_demo_shown"
    }
    
    private val sharedPrefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val userProfileRepository = UserProfileRepository(context)
    
    /**
     * Check if user is currently authenticated using Supabase
     */
    suspend fun isUserAuthenticated(): Boolean {
        return SupabaseService.Auth.isAuthenticated()
    }
    
    /**
     * Check if user profile exists and is complete
     */
    fun isProfileComplete(context: Context): Boolean {
        val profile = userProfileRepository.loadProfile(context)
        return profile != null && profile.firstName.isNotBlank() && profile.lastName.isNotBlank()
    }
    
    /**
     * Check if BMI calculator has been completed
     */
    fun isBMICalculatorCompleted(): Boolean {
        return sharedPrefs.getBoolean(KEY_BMI_CALCULATOR_COMPLETED, false)
    }
    
    /**
     * Mark BMI calculator as completed
     */
    fun markBMICalculatorCompleted() {
        sharedPrefs.edit()
            .putBoolean(KEY_BMI_CALCULATOR_COMPLETED, true)
            .apply()
    }
    
    /**
     * Check if welcome screen has been seen
     */
    fun isWelcomeScreenSeen(): Boolean {
        return sharedPrefs.getBoolean(KEY_WELCOME_SCREEN_SEEN, false)
    }
    
    /**
     * Mark welcome screen as seen
     */
    fun markWelcomeScreenSeen() {
        sharedPrefs.edit()
            .putBoolean(KEY_WELCOME_SCREEN_SEEN, true)
            .apply()
    }
    
    /**
     * Check if onboarding demo has been shown
     */
    fun isOnboardingDemoShown(): Boolean {
        return sharedPrefs.getBoolean(KEY_ONBOARDING_DEMO_SHOWN, false)
    }
    
    /**
     * Mark onboarding demo as shown
     */
    fun markOnboardingDemoShown() {
        sharedPrefs.edit()
            .putBoolean(KEY_ONBOARDING_DEMO_SHOWN, true)
            .apply()
    }
    
    /**
     * Get user details from Supabase Auth
     */
    suspend fun getUserDetails(): UserDetails {
        val user = SupabaseService.Auth.getCurrentUser()
        return UserDetails(
            firstName = user?.userMetadata?.get("first_name") as? String ?: "",
            lastName = user?.userMetadata?.get("last_name") as? String ?: "",
            email = user?.email ?: ""
        )
    }
    
    /**
     * Clear all session data (for logout)
     */
    suspend fun clearSession() {
        sharedPrefs.edit().clear().apply()
        SupabaseService.Auth.signOut()
    }
    
    /**
     * Data class for user details
     */
    data class UserDetails(
        val firstName: String,
        val lastName: String,
        val email: String
    )
}
