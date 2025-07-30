package com.lumoralabs.macro.domain

// Basic Group data model

data class Group(
    val id: String,
    val name: String,
    val members: List<String>
)
