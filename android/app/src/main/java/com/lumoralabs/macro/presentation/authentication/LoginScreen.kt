package com.lumoralabs.macro.presentation.authentication

import androidx.activity.ComponentActivity
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.launch

@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit = {},
    onProfileSetupRequired: () -> Unit = {}
) {
    val context = LocalContext.current
    
    var isSignUp by remember { mutableStateOf(false) }
    var firstName by remember { mutableStateOf("") }
    var lastName by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Spacer(modifier = Modifier.height(60.dp))
        AnimatedLogo()
        Spacer(modifier = Modifier.height(60.dp))
        // Welcome Text
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(horizontal = 24.dp)
        ) {
            Text(
                text = "MACRO",
                fontSize = 42.sp,
                fontWeight = FontWeight.Thin,
                color = Color.White.copy(alpha = 0.95f),
                letterSpacing = 8.sp,
                textAlign = TextAlign.Center
            )
            Text(
                text = "Track. Optimise. Achieve.",
                fontSize = 16.sp,
                fontWeight = FontWeight.Light,
                color = Color.White.copy(alpha = 0.8f),
                letterSpacing = 2.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 8.dp)
            )
        }
        Spacer(modifier = Modifier.height(40.dp))
        
        // Unified email authentication form
        Column(
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // Sign-up specific fields
            if (isSignUp) {
                OutlinedTextField(
                    value = firstName,
                    onValueChange = { firstName = it },
                    label = { Text("First Name", color = Color.White.copy(alpha = 0.7f)) },
                    leadingIcon = { Icon(Icons.Default.Person, null, tint = Color.White.copy(alpha = 0.7f)) },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedBorderColor = Color.White.copy(alpha = 0.7f),
                        unfocusedBorderColor = Color.White.copy(alpha = 0.5f),
                        cursorColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp)
                )
                
                OutlinedTextField(
                    value = lastName,
                    onValueChange = { lastName = it },
                    label = { Text("Last Name", color = Color.White.copy(alpha = 0.7f)) },
                    leadingIcon = { Icon(Icons.Default.Person, null, tint = Color.White.copy(alpha = 0.7f)) },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White,
                        focusedBorderColor = Color.White.copy(alpha = 0.7f),
                        unfocusedBorderColor = Color.White.copy(alpha = 0.5f),
                        cursorColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp)
                )
            }
            
            OutlinedTextField(
                value = email,
                onValueChange = { email = it },
                label = { Text("Email", color = Color.White.copy(alpha = 0.7f)) },
                leadingIcon = { Icon(Icons.Default.Email, null, tint = Color.White.copy(alpha = 0.7f)) },
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    focusedBorderColor = Color.White.copy(alpha = 0.7f),
                    unfocusedBorderColor = Color.White.copy(alpha = 0.5f),
                    cursorColor = Color.White
                ),
                shape = RoundedCornerShape(12.dp)
            )
            
            OutlinedTextField(
                value = password,
                onValueChange = { password = it },
                label = { Text("Password", color = Color.White.copy(alpha = 0.7f)) },
                leadingIcon = { Icon(Icons.Default.Lock, null, tint = Color.White.copy(alpha = 0.7f)) },
                visualTransformation = PasswordVisualTransformation(),
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    focusedBorderColor = Color.White.copy(alpha = 0.7f),
                    unfocusedBorderColor = Color.White.copy(alpha = 0.5f),
                    cursorColor = Color.White
                ),
                shape = RoundedCornerShape(12.dp)
            )
            
            val formComplete = if (isSignUp) {
                firstName.isNotBlank() && lastName.isNotBlank() && email.isNotBlank() && password.isNotBlank()
            } else {
                email.isNotBlank() && password.isNotBlank()
            }
            
            Button(
                onClick = {
                    errorMessage = null
                    val activity = context as? ComponentActivity
                    activity?.lifecycleScope?.launch {
                        try {
                            if (isSignUp) {
                                com.lumoralabs.macro.data.SupabaseService.Auth
                                    .signUpWithEmail(context, email, password)
                            } else {
                                com.lumoralabs.macro.data.SupabaseService.Auth
                                    .signInWithEmail(context, email, password)
                            }
                            onLoginSuccess()
                        } catch (e: Exception) {
                            errorMessage = e.message ?: "Authentication failed"
                        }
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = formComplete,
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF2196F3)),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text(
                    text = if (isSignUp) "Create Account" else "Sign In",
                    color = Color.White,
                    fontWeight = FontWeight.Medium
                )
            }
            
            TextButton(
                onClick = {
                    isSignUp = !isSignUp
                    errorMessage = null
                }
            ) {
                Text(
                    text = if (isSignUp) "Already have an account? Sign in" else "New user? Create an account",
                    color = Color.White.copy(alpha = 0.8f),
                    fontSize = 14.sp
                )
            }
        }
        
        errorMessage?.let {
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = it,
                color = Color.Red,
                fontSize = 12.sp,
                textAlign = TextAlign.Center
            )
        }
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
