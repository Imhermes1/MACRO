package com.lumoralabs.macro.domain

data class UserProfile(
    val firstName: String,
    val lastName: String?,
    val age: Int,
    val dob: String?,
    val height: Float,
    val weight: Float,
    val gender: String = "Male",
    val goal: String? = null,
    val activityLevel: String? = null,
    val macroPreference: String? = null,
    val customDiet: String? = null
)
