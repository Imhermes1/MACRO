package com.lumoralabs.macro.domain

data class UserProfile(
    val firstName: String,
    val lastName: String?,
    val age: Int,
    val dob: String?,
    val height: Float,
    val weight: Float
)
