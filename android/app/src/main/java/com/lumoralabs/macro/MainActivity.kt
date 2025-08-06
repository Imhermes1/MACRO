package com.lumoralabs.macro

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowCompat
import com.lumoralabs.macro.presentation.navigation.SimpleNavigation
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme

/**
 * MainActivity using Navigation Compose with Supabase authentication.
 * Clean architecture following Android best practices.
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)

        setContent {
            MacroTheme {
                UniversalBackground {
                    SimpleNavigation()
                }
            }
        }
    }
}