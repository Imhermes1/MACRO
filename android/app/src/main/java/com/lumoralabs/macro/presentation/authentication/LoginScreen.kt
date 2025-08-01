package com.lumoralabs.macro.presentation.authentication

import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.auth.FirebaseAuth
import com.lumoralabs.macro.data.UserProfileRepository
import com.lumoralabs.macro.ui.components.PillButton

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit = {},
    onProfileSetupRequired: () -> Unit = {}
) {
    val auth = FirebaseAuth.getInstance()
    val context = LocalContext.current
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        
        Spacer(modifier = Modifier.height(60.dp))
        
        // Animated Logo Section
        AnimatedLogo()
        
        Spacer(modifier = Modifier.height(60.dp))
        
        // Welcome Text
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(horizontal = 24.dp)
        ) {
            Text(
                text = "Welcome to",
                fontSize = 28.sp,
                fontWeight = FontWeight.Light,
                color = Color.White.copy(alpha = 0.9f),
                textAlign = TextAlign.Center
            )
            
            Text(
                text = "MACRO",
                fontSize = 48.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 8.dp)
            )
            
            Text(
                text = "Your personalized nutrition companion",
                fontSize = 16.sp,
                fontWeight = FontWeight.Normal,
                color = Color.White.copy(alpha = 0.7f),
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 16.dp)
            )
        }
        
        Spacer(modifier = Modifier.height(60.dp))
        
        // Login Buttons
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            
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
                                    onProfileSetupRequired()
                                } else {
                                    onLoginSuccess()
                                }
                            } else {
                                Toast.makeText(context, "Anonymous login failed!", Toast.LENGTH_SHORT).show()
                            }
                        }
                }
            )
            
            Spacer(modifier = Modifier.height(40.dp))
        }
        
        Spacer(modifier = Modifier.height(40.dp))
    }
}

@Composable
fun AnimatedLogo() {
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
        contentAlignment = Alignment.Center,
        modifier = Modifier.size(120.dp)
    ) {
        // Glow effect background - Only active animation
        Box(
            modifier = Modifier
                .size(120.dp + (20.dp * glowAnimation))
                .alpha(0.3f * glowAnimation)
                .background(
                    brush = Brush.radialGradient(
                        colors = listOf(
                            Color(0xFF4FC3F7),
                            Color.Transparent
                        )
                    ),
                    shape = RoundedCornerShape(50)
                )
        )
        
        // Logo container - No pulse animation
        Card(
            modifier = Modifier
                .size(100.dp), // Static size
            shape = RoundedCornerShape(50),
            colors = CardDefaults.cardColors(
                containerColor = Color.White.copy(alpha = 0.1f)
            ),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.fillMaxSize()
            ) {
                Text(
                    text = "M",
                    fontSize = 48.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                
                // Sparkle overlay - Disabled for stability
                // Box(
                //     modifier = Modifier
                //         .fillMaxSize()
                //         .alpha(sparkleAnimation)
                //         .background(
                //             brush = Brush.radialGradient(
                //                 colors = listOf(
                //                     Color.White.copy(alpha = 0.3f),
                //                     Color.Transparent
                //                 )
                //             )
                //         )
                // )
            }
        }
    }
}
