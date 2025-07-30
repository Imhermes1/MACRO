package com.lumoralabs.macro.data

import android.content.Context
import android.content.SharedPreferences
import com.lumoralabs.macro.domain.UserProfile
import org.json.JSONObject

object UserProfileRepository {
    private const val PREFS_NAME = "user_profile"
    private const val PROFILE_KEY = "profile"

    fun saveProfile(context: Context, profile: UserProfile) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val obj = JSONObject()
        obj.put("firstName", profile.firstName)
        obj.put("lastName", profile.lastName)
        obj.put("age", profile.age)
        obj.put("dob", profile.dob)
        obj.put("height", profile.height)
        obj.put("weight", profile.weight)
        prefs.edit().putString(PROFILE_KEY, obj.toString()).apply()
    }

    fun loadProfile(context: Context): UserProfile? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(PROFILE_KEY, null) ?: return null
        val obj = JSONObject(json)
        return UserProfile(
            firstName = obj.getString("firstName"),
            lastName = obj.optString("lastName", null),
            age = obj.getInt("age"),
            dob = obj.optString("dob", null),
            height = obj.getDouble("height").toFloat(),
            weight = obj.getDouble("weight").toFloat()
        )
    }
}
