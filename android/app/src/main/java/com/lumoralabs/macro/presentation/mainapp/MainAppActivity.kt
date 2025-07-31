package com.lumoralabs.macro.presentation.mainapp

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat
import com.lumoralabs.macro.presentation.authentication.SessionManager
import com.lumoralabs.macro.presentation.onboarding.OnboardingDemoDialog
import com.lumoralabs.macro.presentation.components.FloatingInputBar
import com.lumoralabs.macro.presentation.components.NavigationBar
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme

/**
 * MainAppActivity contains the main calorie tracking interface.
 * Based on Material Design guidelines for complex layouts:
 * https://developer.android.com/develop/ui/compose/layouts/basics
 */
class MainAppActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        setContent {
            MacroTheme {
                UniversalBackground {
                    MainAppScreen()
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainAppScreen() {
    val context = LocalContext.current
    val sessionManager = remember { SessionManager.getInstance(context) }
    var showOnboardingDemo by remember { mutableStateOf(!sessionManager.isOnboardingDemoShown()) }
    
    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
                .padding(top = 28.dp) // Reduced top padding for better balance
        ) {
            // Top Navigation Bar
            NavigationBar(
                showRightButton = true,
                onLeftClick = {
                    // Navigate back or show menu
                },
                onRightClick = {
                    // Navigate to profile/settings
                }
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Daily Progress Card
            DailyProgressCard()
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Quick Stats
            QuickStatsRow()
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Recent Meals Section
            RecentMealsSection()
            
            Spacer(modifier = Modifier.weight(1f))
        }
        
        // Floating Calorie Input Bar
        FloatingInputBar(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(16.dp)
        )
        
        // Show onboarding demo for new users
        if (showOnboardingDemo) {
            OnboardingDemoDialog(
                onDismiss = {
                    sessionManager.markOnboardingDemoShown()
                    showOnboardingDemo = false
                }
            )
        }
    }
}

@Composable
fun DailyProgressCard() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Today's Progress",
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
                Text(
                    text = "Jan 31",
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color.White.copy(alpha = 0.7f)
                )
            }
            
            // Calorie Progress Circle
            Box(
                modifier = Modifier.fillMaxWidth(),
                contentAlignment = Alignment.Center
            ) {
                CalorieProgressCircle(
                    current = 1450,
                    target = 2000
                )
            }
            
            // Macro breakdown
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                MacroItem("Protein", "120g", "150g", Color.Cyan)
                MacroItem("Carbs", "180g", "200g", Color(0xFF00CED1)) // DarkTurquoise/Mint equivalent
                MacroItem("Fat", "65g", "80g", Color.Magenta)
            }
        }
    }
}

@Composable
fun CalorieProgressCircle(
    current: Int,
    target: Int
) {
    val progress = (current.toFloat() / target.toFloat()).coerceIn(0f, 1f)
    
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier.size(120.dp)
    ) {
        // Background circle
        Box(
            modifier = Modifier
                .size(120.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.1f))
        )
        
        // Progress circle (simplified - in production use Canvas for proper arc)
        Box(
            modifier = Modifier
                .size(100.dp)
                .clip(CircleShape)
                .background(
                    Brush.sweepGradient(
                        colors = listOf(
                            Color.Transparent,
                            color.copy(alpha = progress),
                            Color.Transparent
                        )
                    )
                )
        )
        
        // Center text
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "$current",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            Text(
                text = "/ $target cal",
                style = MaterialTheme.typography.bodySmall,
                color = Color.White.copy(alpha = 0.7f)
            )
        }
    }
}

@Composable
fun MacroItem(
    name: String,
    current: String,
    target: String,
    color: Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .clip(CircleShape)
                .background(color)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = name,
            style = MaterialTheme.typography.bodySmall,
            color = Color.White.copy(alpha = 0.7f)
        )
        Text(
            text = "$current / $target",
            style = MaterialTheme.typography.bodySmall,
            fontWeight = FontWeight.Medium,
            color = Color.White
        )
    }
}

@Composable
fun QuickStatsRow() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        QuickStatCard(
            icon = Icons.Default.LocalFireDepartment,
            value = "342",
            label = "Burned",
            color = Color.Red
        )
        QuickStatCard(
            icon = Icons.Default.Water,
            value = "6/8",
            label = "Glasses",
            color = Color.Cyan
        )
        QuickStatCard(
            icon = Icons.Default.DirectionsWalk,
            value = "8,234",
            label = "Steps",
            color = Color(0xFF32CD32) // LimeGreen
        )
    }
}

@Composable
fun QuickStatCard(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    value: String,
    label: String,
    color: Color
) {
    Card(
        modifier = Modifier
            .width(100.dp)
            .height(80.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.1f)
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = color,
                modifier = Modifier.size(20.dp)
            )
            Text(
                text = value,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            Text(
                text = label,
                style = MaterialTheme.typography.bodySmall,
                color = Color.White.copy(alpha = 0.7f)
            )
        }
    }
}

@Composable
fun RecentMealsSection() {
    Column {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Recent Meals",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            TextButton(
                onClick = { /* Navigate to meals history */ }
            ) {
                Text(
                    text = "View All",
                    color = Color.White.copy(alpha = 0.7f)
                )
            }
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Placeholder meal items
        MealItem("Breakfast", "Oatmeal with berries", "420 cal")
        Spacer(modifier = Modifier.height(8.dp))
        MealItem("Lunch", "Grilled chicken salad", "580 cal")
        Spacer(modifier = Modifier.height(8.dp))
        MealItem("Snack", "Greek yogurt", "150 cal")
    }
}

@Composable
fun MealItem(
    mealType: String,
    description: String,
    calories: String
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.05f)
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = mealType,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Medium,
                    color = Color.White
                )
                Text(
                    text = description,
                    style = MaterialTheme.typography.bodySmall,
                    color = Color.White.copy(alpha = 0.7f)
                )
            }
            Text(
                text = calories,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }
    }
}
