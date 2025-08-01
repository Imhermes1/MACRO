package com.lumoralabs.macro.presentation.onboarding

import android.content.Intent
import android.os.Bundle
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat
import com.lumoralabs.macro.data.UserProfileRepository
import com.lumoralabs.macro.presentation.authentication.SessionManager
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme
import kotlinx.coroutines.delay

/**
 * WelcomeActivity with magical glow effects matching iOS implementation.
 * Based on Material Design animation principles:
 * https://developer.android.com/develop/ui/compose/animation
 */
class WelcomeActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        setContent {
            MacroTheme {
                UniversalBackground {
                    WelcomeScreen(
                        onNavigateToBMI = {
                            val intent = Intent(this, BMICalculatorActivity::class.java)
                            startActivity(intent)
                            finish()
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun WelcomeScreen(
    onNavigateToBMI: () -> Unit = {}
) {
    val context = LocalContext.current
    val sessionManager = remember { SessionManager.getInstance(context) }
    
    var showAnimation by remember { mutableStateOf(false) }
    var showSecondaryElements by remember { mutableStateOf(false) }
    
    // Get first name from profile
    val firstName = remember {
        val userDetails = sessionManager.getUserDetails()
        userDetails.firstName.takeIf { it.isNotBlank() }
    }
    
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
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Spacer(modifier = Modifier.weight(1f))
        
        // Welcome content
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // Animated logo with enhanced glow
            AnimatedWelcomeLogo(
                modifier = Modifier
                    .scale(if (showAnimation) 1.0f else 0.8f)
                    .graphicsLayer { alpha = if (showAnimation) 1.0f else 0.0f }
            )
            
            // Welcome message
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                AnimatedText(
                    text = "Welcome to",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White.copy(alpha = 0.9f),
                    show = showSecondaryElements,
                    delay = 800
                )
                
                AnimatedText(
                    text = "MACRO",
                    fontSize = 48.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    show = showSecondaryElements,
                    delay = 1000,
                    hasShadow = true
                )
                
                firstName?.let {
                    AnimatedText(
                        text = "Hi $it! 👋",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = Color.White.copy(alpha = 0.9f),
                        show = showSecondaryElements,
                        delay = 1200
                    )
                }
                
                AnimatedText(
                    text = "Your nutrition journey starts here",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White.copy(alpha = 0.8f),
                    show = showSecondaryElements,
                    delay = 1400,
                    textAlign = TextAlign.Center
                )
            }
            
            // Feature highlights
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier
                    .scale(if (showSecondaryElements) 1.0f else 0.9f)
                    .graphicsLayer { alpha = if (showSecondaryElements) 1.0f else 0.0f }
            ) {
                WelcomeFeatureRow(
                    icon = Icons.Default.TrendingUp,
                    title = "Track your macros",
                    delay = 1600
                )
                WelcomeFeatureRow(
                    icon = Icons.Default.GpsFixed,
                    title = "Reach your goals",
                    delay = 1800
                )
                WelcomeFeatureRow(
                    icon = Icons.Default.Favorite,
                    title = "Stay healthy",
                    delay = 2000
                )
            }
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        // Continue button
        AnimatedVisibility(
            visible = showSecondaryElements,
            enter = fadeIn(animationSpec = tween(800, delayMillis = 2200)) + 
                   slideInVertically(animationSpec = tween(800, delayMillis = 2200)) { it / 2 }
        ) {
            Button(
                onClick = {
                    sessionManager.markWelcomeScreenSeen()
                    // Navigate to BMI calculator
                    onNavigateToBMI()
                },
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
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Let's Calculate Your BMI",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Icon(
                        imageVector = Icons.Default.ArrowForward,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }
        
        Spacer(modifier = Modifier.height(40.dp))
    }
}

@Composable
fun AnimatedWelcomeLogo(
    modifier: Modifier = Modifier
) {
    var glow by remember { mutableStateOf(false) }
    var pulse by remember { mutableStateOf(false) }
    var sparkle by remember { mutableStateOf(false) }
    
    LaunchedEffect(Unit) {
        glow = true
        pulse = true
        sparkle = true
    }
    
    // Animation values
    val glowAnimation by animateFloatAsState(
        targetValue = if (glow) 1f else 0.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "glow"
    )
    
    val pulseAnimation by animateFloatAsState(
        targetValue = if (pulse) 1.1f else 0.9f,
        animationSpec = infiniteRepeatable(
            animation = tween(2500, easing = EaseInOut),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )
    
    val sparkleAnimation by animateFloatAsState(
        targetValue = if (sparkle) 0.7f else 0.2f,
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
        // Outer magical aura
        Box(
            modifier = Modifier
                .size((240 + glowAnimation * 80).dp)
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            Color.Yellow.copy(alpha = glowAnimation * 0.3f),
                            Color.White.copy(alpha = glowAnimation * 0.2f),
                            Color.Transparent
                        ),
                        radius = 160f + glowAnimation * 60f
                    )
                )
                .blur(15.dp)
                .scale(pulseAnimation)
        )
        
        // Main logo with enhanced shadows
        Box(
            modifier = Modifier
                .size(200.dp)
                .scale(pulseAnimation),
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
fun AnimatedText(
    text: String,
    fontSize: androidx.compose.ui.unit.TextUnit,
    fontWeight: FontWeight,
    color: Color,
    show: Boolean,
    delay: Long,
    hasShadow: Boolean = false,
    textAlign: TextAlign = TextAlign.Start
) {
    val animatedScale by animateFloatAsState(
        targetValue = if (show) 1.0f else 0.9f,
        animationSpec = tween(600, delayMillis = delay.toInt()),
        label = "text_scale"
    )
    
    val animatedAlpha by animateFloatAsState(
        targetValue = if (show) 1.0f else 0.0f,
        animationSpec = tween(600, delayMillis = delay.toInt()),
        label = "text_alpha"
    )
    
    Text(
        text = text,
        fontSize = fontSize,
        fontWeight = fontWeight,
        color = color,
        textAlign = textAlign,
        modifier = Modifier
            .scale(animatedScale)
            .graphicsLayer { alpha = animatedAlpha }
            .then(
                if (hasShadow) {
                    Modifier.graphicsLayer {
                        shadowElevation = 10f
                    }
                } else Modifier
            )
    )
}

@Composable
fun WelcomeFeatureRow(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    title: String,
    delay: Long
) {
    var show by remember { mutableStateOf(false) }
    
    LaunchedEffect(Unit) {
        delay(delay)
        show = true
    }
    
    val animatedScale by animateFloatAsState(
        targetValue = if (show) 1.0f else 0.8f,
        animationSpec = tween(600),
        label = "feature_scale"
    )
    
    val animatedAlpha by animateFloatAsState(
        targetValue = if (show) 1.0f else 0.0f,
        animationSpec = tween(600),
        label = "feature_alpha"
    )
    
    Row(
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .scale(animatedScale)
            .graphicsLayer { alpha = animatedAlpha }
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = Color.White,
            modifier = Modifier.size(24.dp)
        )
        
        Text(
            text = title,
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium,
            color = Color.White.copy(alpha = 0.9f)
        )
        
        Spacer(modifier = Modifier.weight(1f))
    }
}
