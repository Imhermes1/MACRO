package com.lumoralabs.macro

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.core.view.WindowCompat
import com.lumoralabs.macro.presentation.authentication.SessionManager
import com.lumoralabs.macro.presentation.navigation.MacroNavigation
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme

/**
 * MainActivity using Navigation Compose instead of activity-based navigation.
 * Based on Navigation Compose best practices:
 * https://developer.android.com/guide/navigation/navigation-compose
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)

        setContent {
            MacroTheme {
                val context = LocalContext.current
                val sessionManager = remember { SessionManager.getInstance(context) }
                
                UniversalBackground {
                    MacroNavigation(sessionManager = sessionManager)
                }
            }
        }
    }
}