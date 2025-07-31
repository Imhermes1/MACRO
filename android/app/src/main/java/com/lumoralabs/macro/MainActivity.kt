package com.lumoralabs.macro

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.auth.FirebaseAuth
import com.lumoralabs.macro.presentation.authentication.SessionManager
import com.lumoralabs.macro.presentation.authentication.LoginActivity
import com.lumoralabs.macro.presentation.onboarding.ProfileSetupActivity
import com.lumoralabs.macro.presentation.onboarding.EnhancedWelcomeActivity
import com.lumoralabs.macro.presentation.onboarding.BMICalculatorActivity
import com.lumoralabs.macro.presentation.mainapp.MainAppActivity
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            MacroTheme {
                AppNavigationRoot()
            }
        }
    }
}

@Composable
fun AppNavigationRoot() {
    val context = LocalContext.current
    val sessionManager = remember { SessionManager.getInstance(context) }
    
    if (!sessionManager.isUserAuthenticated()) {
        // User not logged in, show login
        LaunchedEffect(Unit) {
            val intent = Intent(context, LoginActivity::class.java)
            context.startActivity(intent)
            (context as ComponentActivity).finish()
        }
        // Show loading or empty state while redirecting
        UniversalBackground {
            Box(modifier = Modifier.fillMaxSize())
        }
    } else {
        // User is logged in, check profile completion
        if (!sessionManager.isProfileComplete(context)) {
            // Profile incomplete, show profile setup
            LaunchedEffect(Unit) {
                val intent = Intent(context, ProfileSetupActivity::class.java)
                context.startActivity(intent)
                (context as ComponentActivity).finish()
            }
            UniversalBackground {
                Box(modifier = Modifier.fillMaxSize())
            }
        } else if (!sessionManager.isWelcomeScreenSeen()) {
            // Profile complete but welcome not seen, show welcome
            LaunchedEffect(Unit) {
                val intent = Intent(context, EnhancedWelcomeActivity::class.java)
                context.startActivity(intent)
                (context as ComponentActivity).finish()
            }
            UniversalBackground {
                Box(modifier = Modifier.fillMaxSize())
            }
        } else if (!sessionManager.isBMICalculatorCompleted()) {
            // Welcome seen but BMI not calculated, show BMI calculator
            LaunchedEffect(Unit) {
                val intent = Intent(context, BMICalculatorActivity::class.java)
                context.startActivity(intent)
                (context as ComponentActivity).finish()
            }
            UniversalBackground {
                Box(modifier = Modifier.fillMaxSize())
            }
        } else {
            // Everything complete, show main app
            LaunchedEffect(Unit) {
                val intent = Intent(context, MainAppActivity::class.java)
                context.startActivity(intent)
                (context as ComponentActivity).finish()
            }
            UniversalBackground {
                Box(modifier = Modifier.fillMaxSize())
            }
        }
    }
}

@Composable
fun MainAppContent() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Welcome to MACRO!",
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
        Spacer(modifier = Modifier.height(20.dp))
        Text(
            text = "Your nutrition tracking app",
            fontSize = 18.sp,
            color = Color.White.copy(alpha = 0.8f)
        )
    }
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    MacroTheme {
        Greeting("Android")
    }
}