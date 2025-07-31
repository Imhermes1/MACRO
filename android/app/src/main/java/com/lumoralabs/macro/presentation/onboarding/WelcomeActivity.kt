package com.lumoralabs.macro.presentation.onboarding

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat
import com.lumoralabs.macro.data.UserProfileRepository
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme
import kotlinx.coroutines.delay

class WelcomeActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        setContent {
            MacroTheme {
                UniversalBackground {
                    WelcomeScreen()
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WelcomeScreen() {
    val context = LocalContext.current
    var showAnimation by remember { mutableStateOf(false) }
    var showSecondaryElements by remember { mutableStateOf(false) }
    
    val profileRepo = remember { UserProfileRepository(context) }
    
    // Get first name from profile
    val firstName = remember {
        profileRepo.loadProfile()?.firstName
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
            // Animated logo placeholder (since we don't have the logo in Android assets)
            AnimatedWelcomeLogo(showAnimation = showAnimation)
            
            // Welcome message
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                AnimatedText(
                    text = "Welcome to",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Medium,
                    show = showSecondaryElements,
                    delay = 0
                )
                
                AnimatedText(
                    text = "MACRO",
                    fontSize = 48.sp,
                    fontWeight = FontWeight.Bold,
                    show = showSecondaryElements,
                    delay = 200
                )
                
                firstName?.let { name ->
                    AnimatedText(
                        text = "Hi $name! 👋",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.SemiBold,
                        show = showSecondaryElements,
                        delay = 400
                    )
                }
                
                AnimatedText(
                    text = "Your nutrition journey starts here",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Medium,
                    show = showSecondaryElements,
                    delay = 600,
                    alpha = 0.8f
                )
            }
            
            // Feature highlights
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                FeatureRow(
                    icon = Icons.Default.TrendingUp,
                    title = "Track your macros",
                    show = showSecondaryElements,
                    delay = 800
                )
                FeatureRow(
                    icon = Icons.Default.TrackChanges,
                    title = "Reach your goals",
                    show = showSecondaryElements,
                    delay = 1000
                )
                FeatureRow(
                    icon = Icons.Default.Favorite,
                    title = "Stay healthy",
                    show = showSecondaryElements,
                    delay = 1200
                )
            }
        }
        
        Spacer(modifier = Modifier.weight(1f))
        
        // Continue button
        AnimatedContinueButton(
            show = showSecondaryElements,
            delay = 1400,
            onClick = {
                // Navigate to BMI Calculator
                val intent = Intent(context, BMICalculatorActivity::class.java)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                context.startActivity(intent)
                (context as ComponentActivity).finish()
            }
        )
    }
}

@Composable
fun AnimatedWelcomeLogo(showAnimation: Boolean) {
    val scale by animateFloatAsState(
        targetValue = if (showAnimation) 1f else 0.8f,
        animationSpec = tween(1200, easing = EaseOut),
        label = "logo_scale"
    )
    
    val alpha by animateFloatAsState(
        targetValue = if (showAnimation) 1f else 0f,
        animationSpec = tween(1200, easing = EaseOut),
        label = "logo_alpha"
    )
    
    // Logo placeholder with glow effect
    Card(
        modifier = Modifier
            .size(200.dp)
            .scale(scale),
        shape = RoundedCornerShape(100.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = alpha * 0.1f)
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
    ) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "MACRO",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White.copy(alpha = alpha),
                textAlign = TextAlign.Center
            )
        }
    }
}

@Composable
fun AnimatedText(
    text: String,
    fontSize: androidx.compose.ui.unit.TextUnit,
    fontWeight: FontWeight,
    show: Boolean,
    delay: Int,
    alpha: Float = 1f
) {
    val scale by animateFloatAsState(
        targetValue = if (show) 1f else 0.9f,
        animationSpec = tween(800, delayMillis = delay, easing = EaseOut),
        label = "text_scale"
    )
    
    val textAlpha by animateFloatAsState(
        targetValue = if (show) alpha else 0f,
        animationSpec = tween(800, delayMillis = delay, easing = EaseOut),
        label = "text_alpha"
    )
    
    Text(
        text = text,
        fontSize = fontSize,
        fontWeight = fontWeight,
        color = Color.White.copy(alpha = textAlpha),
        textAlign = TextAlign.Center,
        modifier = Modifier.scale(scale)
    )
}

@Composable
fun FeatureRow(
    icon: ImageVector,
    title: String,
    show: Boolean,
    delay: Int
) {
    val scale by animateFloatAsState(
        targetValue = if (show) 1f else 0.8f,
        animationSpec = tween(600, delayMillis = delay, easing = EaseOut),
        label = "feature_scale"
    )
    
    val alpha by animateFloatAsState(
        targetValue = if (show) 1f else 0f,
        animationSpec = tween(600, delayMillis = delay, easing = EaseOut),
        label = "feature_alpha"
    )
    
    Row(
        modifier = Modifier
            .scale(scale)
            .padding(horizontal = 40.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = Color.White.copy(alpha = alpha),
            modifier = Modifier.size(24.dp)
        )
        
        Text(
            text = title,
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium,
            color = Color.White.copy(alpha = alpha * 0.9f)
        )
        
        Spacer(modifier = Modifier.weight(1f))
    }
}

@Composable
fun AnimatedContinueButton(
    show: Boolean,
    delay: Int,
    onClick: () -> Unit
) {
    val scale by animateFloatAsState(
        targetValue = if (show) 1f else 0.9f,
        animationSpec = tween(800, delayMillis = delay, easing = EaseOut),
        label = "button_scale"
    )
    
    val alpha by animateFloatAsState(
        targetValue = if (show) 1f else 0f,
        animationSpec = tween(800, delayMillis = delay, easing = EaseOut),
        label = "button_alpha"
    )
    
    Button(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .scale(scale),
        shape = RoundedCornerShape(30.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color.White.copy(alpha = alpha * 0.25f),
            contentColor = Color.White.copy(alpha = alpha)
        ),
        elevation = ButtonDefaults.buttonElevation(defaultElevation = 8.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Let's Calculate Your BMI",
                fontSize = 18.sp,
                fontWeight = FontWeight.SemiBold
            )
            Icon(
                imageVector = Icons.Default.ArrowForward,
                contentDescription = null,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}
