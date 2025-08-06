package com.lumoralabs.macro.presentation.navigation

import kotlinx.serialization.Serializable

/**
 * Type-safe navigation destinations for the MACRO app.
 * Using Kotlin Serialization for type safety with Navigation Compose.
 * Based on Navigation Compose best practices:
 * https://developer.android.com/guide/navigation/navigation-compose
 */
@Serializable
sealed class MacroDestination {
    @Serializable
    data object Login : MacroDestination()
    
    @Serializable
    data object ProfileSetup : MacroDestination()
    
    @Serializable
    data object GoalsSetup : MacroDestination()
    
    @Serializable
    data object MainApp : MacroDestination()
    
    @Serializable
    data object Settings : MacroDestination()
}
