package com.lumoralabs.macro.presentation.authentication

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat
import com.google.firebase.auth.FirebaseAuth
import com.lumoralabs.macro.presentation.onboarding.ProfileSetupActivity
import com.lumoralabs.macro.presentation.mainapp.MainAppActivity
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme
import kotlinx.coroutines.delay

/**
 * LoginActivity with magical glow effects for the logo.
 * Based on Firebase Authentication best practices:
 * https://firebase.google.com/docs/auth/android/start
 * 
 * UI inspired by Material Design 3 principles:
 * https://developer.android.com/develop/ui/compose/designsystems/material3
 */
class LoginActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        setContent {
            MacroTheme {
                UniversalBackground {
                    LoginScreen()
                }
            }
        }
    }
}

@Composable
fun LoginScreen() {
    val auth = FirebaseAuth.getInstance()
    val context = LocalContext.current
    val sessionManager = remember { SessionManager.getInstance(context) }
    
    var showAnimation by remember { mutableStateOf(false) }
    var showSecondaryElements by remember { mutableStateOf(false) }
    
    LaunchedEffect(Unit) {
        delay(300)
        showAnimation = true
        delay(800)
        showSecondaryElements = true
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.weight(1f))
        
        // Animated logo with magical glow effects
        AnimatedGlowLogo(
            modifier = Modifier
                .scale(if (showAnimation) 1.0f else 0.8f)
                .graphicsLayer { alpha = if (showAnimation) 1.0f else 0.0f }
        )
        
        Spacer(modifier = Modifier.height(40.dp))
        
        // App title with animation
        Text(
            text = "Welcome to MACRO",
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White,
            modifier = Modifier
                .scale(if (showSecondaryElements) 1.0f else 0.9f)
                .graphicsLayer { alpha = if (showSecondaryElements) 1.0f else 0.0f }
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Text(
            text = "Your nutrition journey starts here",
            fontSize = 16.sp,
            color = Color.White.copy(alpha = 0.8f),
            modifier = Modifier
                .scale(if (showSecondaryElements) 1.0f else 0.9f)
                .graphicsLayer { alpha = if (showSecondaryElements) 1.0f else 0.0f }
        )
        
        Spacer(modifier = Modifier.height(60.dp))
        
        // Login Buttons with staggered animations
        AnimatedVisibility(
            visible = showSecondaryElements,
            enter = fadeIn(animationSpec = tween(800)) + 
                   slideInVertically(animationSpec = tween(800)) { it / 2 }
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                PillButton(
                    text = "Login with Email",
                    icon = Icons.Default.Email,
                    onClick = {
                        // Show email login dialog/modal
                        Toast.makeText(context, "Email login not implemented yet", Toast.LENGTH_SHORT).show()
                    }
                )
                
                PillButton(
                    text = "Login Anonymously (Demo)",
                    icon = Icons.Default.Person,
                    onClick = {
                        auth.signInAnonymously()
                            .addOnCompleteListener { task ->
                                if (task.isSuccessful) {
                                    // For demo purposes, simulate user profile data
                                    val user = auth.currentUser
                                    val profileUpdates = com.google.firebase.auth.UserProfileChangeRequest.Builder()
                                        .setDisplayName("Demo User")
                                        .build()
                                    user?.updateProfile(profileUpdates)
                                    
                                    val profile = com.lumoralabs.macro.data.UserProfileRepository.loadProfile(context)
                                    if (profile == null) {
                                        val intent = Intent(context, ProfileSetupActivity::class.java)
                                        context.startActivity(intent)
                                        (context as ComponentActivity).finish()
                                    } else {
                                        val intent = Intent(context, MainAppActivity::class.java)
                                        context.startActivity(intent)
                                        (context as ComponentActivity).finish()
                                    }
                                } else {
                                    Toast.makeText(context, "Anonymous login failed!", Toast.LENGTH_SHORT).show()
                                }
                            }
                    }
                )
                
                PillButton(
                    text = "Login with Google",
                    icon = Icons.Default.AccountCircle,
                    onClick = {
                        // Implement Google login
                        Toast.makeText(context, "Google login not implemented yet", Toast.LENGTH_SHORT).show()
                    }
                )
            }
        }
        
        Spacer(modifier = Modifier.weight(1f))
    }
}

@Composable
fun AnimatedGlowLogo(
    modifier: Modifier = Modifier
) {
    var glow by remember { mutableStateOf(false) }
    var pulse by remember { mutableStateOf(false) }
    var sparkle by remember { mutableStateOf(false) }
    
    LaunchedEffect(Unit) {
        // Primary glow animation only - no pulse or sparkle
        glow = true
        // Remove pulse and sparkle for stable UI
        // pulse = true
        // sparkle = true
    }
    
    // Animation values
    val glowAnimation by animateFloatAsState(
        targetValue = if (glow) 1f else 0f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glow"
    )
    
    // Removed pulse animation to eliminate breathing effect
    // val pulseAnimation = 1.0f // Static scale
    
    val sparkleAnimation by animateFloatAsState(
        targetValue = if (sparkle) 1f else 0.2f,
        animationSpec = infiniteRepeatable(
            animation = tween(1300, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "sparkle"
    )
    
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center
    ) {
        // Outer magical aura - static size for stable experience
        Box(
            modifier = Modifier
                .size(250.dp)
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            Color.Yellow.copy(alpha = glowAnimation * 0.3f),
                            Color.White.copy(alpha = glowAnimation * 0.2f),
                            Color.Transparent
                        ),
                        radius = 165f
                    )
                )
                .blur(15.dp)
        )
        
        // Main logo with enhanced shadows - no scaling for stability
        Box(
            modifier = Modifier
                .size(200.dp),
            contentAlignment = Alignment.Center
        ) {
            // Multiple layered shadow effects
            repeat(4) { index ->
                Box(
                    modifier = Modifier
                        .size(200.dp)
                        .clip(CircleShape)
                        .background(
                            when (index) {
                                0 -> if (glow) Color.Yellow.copy(alpha = glowAnimation * 0.9f) else Color.White.copy(alpha = 0.7f)
                                1 -> if (glow) Color.White.copy(alpha = glowAnimation * 0.8f) else Color.Yellow.copy(alpha = 0.6f)
                                2 -> if (glow) Color.Yellow.copy(alpha = glowAnimation * 0.7f) else Color.White.copy(alpha = 0.5f)
                                else -> if (glow) Color.White.copy(alpha = glowAnimation * 0.6f) else Color.Yellow.copy(alpha = 0.3f)
                            }
                        )
                        .blur(
                            when (index) {
                                0 -> if (glow) 80.dp else 40.dp
                                1 -> if (glow) 50.dp else 25.dp
                                2 -> if (glow) 25.dp else 12.dp
                                else -> if (glow) 12.dp else 6.dp
                            }
                        )
                )
            }
            
            // Logo image (placeholder - replace with actual logo)
            Box(
                modifier = Modifier
                    .size(200.dp)
                    .clip(CircleShape)
                    .background(Color.White.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.RestaurantMenu,
                    contentDescription = "MACRO Logo",
                    modifier = Modifier.size(100.dp),
                    tint = Color.White
                )
            }
            
            // Subtle sparkle effect overlay
            Box(
                modifier = Modifier
                    .size(210.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.sweepGradient(
                            colors = listOf(
                                Color.Yellow.copy(alpha = sparkleAnimation * 0.7f),
                                Color.White.copy(alpha = sparkleAnimation * 0.5f),
                                Color.Yellow.copy(alpha = sparkleAnimation * 0.3f),
                                Color.Transparent,
                                Color.Transparent,
                                Color.Transparent
                            )
                        )
                    )
                    .blur(1.5.dp)
            )
        }
    }
}

@Composable
fun PillButton(
    text: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp),
        shape = RoundedCornerShape(28.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color.White.copy(alpha = 0.25f),
            contentColor = Color.White
        )
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = text,
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium
            )
        }
    }
}
