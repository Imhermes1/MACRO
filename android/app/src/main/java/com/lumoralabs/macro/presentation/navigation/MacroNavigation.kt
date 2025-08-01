package com.lumoralabs.macro.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.lumoralabs.macro.presentation.authentication.LoginScreen
import com.lumoralabs.macro.presentation.authentication.SessionManager
import com.lumoralabs.macro.presentation.onboarding.ProfileSetupScreen
import com.lumoralabs.macro.presentation.onboarding.WelcomeScreen
import com.lumoralabs.macro.presentation.onboarding.BMICalculatorScreen
import com.lumoralabs.macro.presentation.onboarding.OnboardingDemoDialog
import com.lumoralabs.macro.presentation.mainapp.MainAppScreen
import com.lumoralabs.macro.presentation.settings.SettingsScreen

/**
 * Main navigation graph for the MACRO app using Navigation Compose.
 * Follows Navigation Compose best practices:
 * https://developer.android.com/guide/navigation/navigation-compose
 */
@Composable
fun MacroNavigation(
    navController: NavHostController = rememberNavController(),
    sessionManager: SessionManager
) {
    val startDestination = remember {
        getStartDestination(sessionManager)
    }

    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        // Authentication Flow
        composable<MacroDestination.Login> {
            LoginScreen(
                onLoginSuccess = { 
                    navController.navigate(MacroDestination.MainApp) {
                        popUpTo<MacroDestination.Login> { inclusive = true }
                    }
                },
                onProfileSetupRequired = {
                    navController.navigate(MacroDestination.ProfileSetup) {
                        popUpTo<MacroDestination.Login> { inclusive = true }
                    }
                }
            )
        }

        // Onboarding Flow
        composable<MacroDestination.ProfileSetup> {
            ProfileSetupScreen(
                onNavigateBack = {
                    navController.popBackStack()
                },
                onNavigateToWelcome = {
                    navController.navigate(MacroDestination.Welcome) {
                        popUpTo<MacroDestination.Login> { inclusive = true }
                    }
                }
            )
        }

        composable<MacroDestination.Welcome> {
            WelcomeScreen(
                onNavigateToBMI = {
                    navController.navigate(MacroDestination.BMICalculator) {
                        popUpTo<MacroDestination.Welcome> { inclusive = true }
                    }
                }
            )
        }

        composable<MacroDestination.BMICalculator> {
            BMICalculatorScreen(
                onNavigateToMainApp = {
                    navController.navigate(MacroDestination.MainApp) {
                        popUpTo<MacroDestination.BMICalculator> { inclusive = true }
                    }
                }
            )
        }

        // Main App Flow
        composable<MacroDestination.MainApp> {
            MainAppScreen(
                onNavigateToSettings = {
                    navController.navigate(MacroDestination.Settings)
                },
                onShowOnboardingDemo = {
                    navController.navigate(MacroDestination.OnboardingDemo)
                }
            )
        }

        composable<MacroDestination.Settings> {
            SettingsScreen(
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        composable<MacroDestination.OnboardingDemo> {
            OnboardingDemoDialog(
                onDismiss = {
                    navController.popBackStack()
                }
            )
        }
    }
}

/**
 * Determines the start destination based on user authentication and onboarding state.
 * Following Supabase Auth and app state management best practices.
 */
private fun getStartDestination(sessionManager: SessionManager): Any {
    return when {
        !sessionManager.isUserAuthenticated() -> MacroDestination.Login
        !sessionManager.isProfileComplete(sessionManager.context) -> MacroDestination.ProfileSetup
        !sessionManager.isWelcomeScreenSeen() -> MacroDestination.Welcome
        !sessionManager.isBMICalculatorCompleted() -> MacroDestination.BMICalculator
        else -> MacroDestination.MainApp
    }
}
