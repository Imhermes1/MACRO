package com.lumoralabs.macro.presentation.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.RadioButtonUnchecked
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.lumoralabs.macro.data.UserProfileRepository
import com.lumoralabs.macro.domain.UserProfile
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GoalsSetupScreen(
    onSetupComplete: () -> Unit = {},
    onSignOut: () -> Unit = {}
) {
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current
    val coroutineScope = rememberCoroutineScope()
    
    var goal by remember { mutableStateOf("Maintain Weight") }
    var activityLevel by remember { mutableStateOf("Sedentary") }
    var macroPreference by remember { mutableStateOf("Balanced") }
    var customDietText by remember { mutableStateOf("") }
    var bmi by remember { mutableStateOf(0.0) }
    var calorieGoal by remember { mutableStateOf(0.0) }
    var isLoading by remember { mutableStateOf(false) }
    var showAlert by remember { mutableStateOf(false) }
    var alertMessage by remember { mutableStateOf("") }
    var profile by remember { mutableStateOf<UserProfile?>(null) }

    // Load profile and calculate BMI
    LaunchedEffect(Unit) {
        profile = UserProfileRepository.loadProfile(context)
        profile?.let {
            if (it.height > 0 && it.weight > 0) {
                val heightInMeters = it.height / 100.0
                bmi = it.weight / (heightInMeters * heightInMeters)
            }
        }
    }

    val bmiColor = when {
        bmi < 18.5 -> Color(0xFF2196F3) // Blue - Underweight
        bmi < 25 -> Color(0xFF4CAF50)   // Green - Normal
        bmi < 30 -> Color(0xFFFF9800)   // Orange - Overweight
        else -> Color(0xFFF44336)       // Red - Obese
    }

    val bmiCategory = when {
        bmi < 18.5 -> "Underweight - You may benefit from gaining weight"
        bmi < 25 -> "Normal weight - You're in a healthy range"
        bmi < 30 -> "Overweight - Consider a healthy weight loss plan"
        else -> "Obese - Consult with a healthcare professional"
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF1a1a1a),
                        Color(0xFF2a2a2a),
                        Color(0xFF1a1a1a)
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(60.dp))
            
            // Header
            Text(
                text = "Goals & Health",
                fontSize = 32.sp,
                fontWeight = FontWeight.Thin,
                color = Color.White.copy(alpha = 0.95f),
                letterSpacing = 4.sp,
                textAlign = TextAlign.Center
            )
            
            Text(
                text = "Set your fitness goals and preferences",
                fontSize = 14.sp,
                fontWeight = FontWeight.Light,
                color = Color.White.copy(alpha = 0.7f),
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp)
            )
            
            Spacer(modifier = Modifier.height(30.dp))
            
            // BMI Display Section
            if (bmi > 0) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = Color.Black.copy(alpha = 0.2f)
                    ),
                    shape = RoundedCornerShape(20.dp)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "Your BMI",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Medium,
                            color = Color.White
                        )
                        
                        Spacer(modifier = Modifier.height(12.dp))
                        
                        Row(
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = String.format("%.1f", bmi),
                                fontSize = 36.sp,
                                fontWeight = FontWeight.Thin,
                                color = bmiColor
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Box(
                                modifier = Modifier
                                    .size(12.dp)
                                    .background(bmiColor, CircleShape)
                            )
                        }
                        
                        Text(
                            text = bmiCategory,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Light,
                            color = Color.White.copy(alpha = 0.7f),
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(top = 8.dp)
                        )
                    }
                }
                
                Spacer(modifier = Modifier.height(24.dp))
            }
            
            // Primary Goal Section
            GoalSection(
                title = "Primary Goal*",
                options = listOf("Lose Weight", "Gain Weight", "Maintain Weight", "Build Muscle", "Improve Fitness", "General Health"),
                selectedOption = goal,
                onOptionSelected = { goal = it },
                isGrid = true
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Activity Level Section
            ActivityLevelSection(
                selectedActivity = activityLevel,
                onActivitySelected = { activityLevel = it }
            )
            
            Spacer(modifier = Modifier.height(24.dp))
            
            // Diet Style Section
            Column(
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = "Diet Style*",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White,
                    modifier = Modifier.padding(bottom = 16.dp)
                )
                
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.height(120.dp) // Fixed height for 2 rows
                ) {
                    items(listOf("Balanced", "High Protein", "Low Carb", "Custom")) { macro ->
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .selectable(
                                    selected = macroPreference == macro,
                                    onClick = { 
                                        macroPreference = macro
                                        if (macro != "Custom") {
                                            customDietText = ""
                                        }
                                    }
                                ),
                            colors = CardDefaults.cardColors(
                                containerColor = Color.Black.copy(alpha = 0.2f)
                            ),
                            shape = RoundedCornerShape(15.dp),
                            border = CardDefaults.outlinedCardBorder().copy(
                                brush = if (macroPreference == macro) 
                                    Brush.horizontalGradient(listOf(Color.Blue, Color.Blue))
                                else 
                                    Brush.horizontalGradient(listOf(Color.Black, Color.Black))
                            )
                        ) {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(12.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = macro,
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Medium,
                                    color = Color.White,
                                    textAlign = TextAlign.Center
                                )
                            }
                        }
                    }
                }
                
                // Custom diet text field
                if (macroPreference == "Custom") {
                    Spacer(modifier = Modifier.height(16.dp))
                    
                    Text(
                        text = "Describe your custom diet preference:",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                        color = Color.White.copy(alpha = 0.8f),
                        modifier = Modifier.padding(bottom = 8.dp)
                    )
                    
                    OutlinedTextField(
                        value = customDietText,
                        onValueChange = { customDietText = it },
                        placeholder = { 
                            Text(
                                "e.g., Keto, Paleo, Mediterranean, etc.",
                                color = Color.White.copy(alpha = 0.5f)
                            ) 
                        },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = Color.Blue.copy(alpha = 0.5f),
                            unfocusedBorderColor = Color.White.copy(alpha = 0.3f),
                            cursorColor = Color.White
                        ),
                        shape = RoundedCornerShape(20.dp),
                        keyboardOptions = KeyboardOptions(imeAction = ImeAction.Done),
                        keyboardActions = KeyboardActions(onDone = { focusManager.clearFocus() })
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(40.dp))
            
            // Complete Setup Button
            Button(
                onClick = {
                    focusManager.clearFocus()
                    coroutineScope.launch {
                        validateAndCompleteSetup(
                            goal = goal,
                            activityLevel = activityLevel,
                            macroPreference = macroPreference,
                            customDietText = customDietText,
                            profile = profile,
                            context = context,
                            onError = { message ->
                                alertMessage = message
                                showAlert = true
                            },
                            onLoading = { loading ->
                                isLoading = loading
                            },
                            onSuccess = onSetupComplete
                        )
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                enabled = !isLoading,
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.Blue
                ),
                shape = RoundedCornerShape(25.dp)
            ) {
                if (isLoading) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(20.dp),
                            color = Color.White,
                            strokeWidth = 2.dp
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Setting up...")
                    }
                } else {
                    Text(
                        text = "Complete Setup",
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 16.sp
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(40.dp))
        }
        
        // Sign Out Button (bottom right)
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            contentAlignment = Alignment.BottomEnd
        ) {
            IconButton(
                onClick = onSignOut,
                modifier = Modifier
                    .background(
                        color = Color.Black.copy(alpha = 0.3f),
                        shape = CircleShape
                    )
                    .size(48.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Info, // Replace with power icon when available
                    contentDescription = "Sign Out",
                    tint = Color.Red.copy(alpha = 0.8f),
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
    
    // Alert Dialog
    if (showAlert) {
        AlertDialog(
            onDismissRequest = { showAlert = false },
            title = { Text("Setup") },
            text = { Text(alertMessage) },
            confirmButton = {
                TextButton(onClick = { showAlert = false }) {
                    Text("OK")
                }
            }
        )
    }
}

@Composable
fun GoalSection(
    title: String,
    options: List<String>,
    selectedOption: String,
    onOptionSelected: (String) -> Unit,
    isGrid: Boolean = true
) {
    Column(
        modifier = Modifier.fillMaxWidth()
    ) {
        Text(
            text = title,
            fontSize = 18.sp,
            fontWeight = FontWeight.Medium,
            color = Color.White,
            modifier = Modifier.padding(bottom = 16.dp)
        )
        
        if (isGrid) {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.height(180.dp) // Fixed height for 3 rows
            ) {
                items(options) { option ->
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .selectable(
                                selected = selectedOption == option,
                                onClick = { onOptionSelected(option) }
                            ),
                        colors = CardDefaults.cardColors(
                            containerColor = Color.Black.copy(alpha = 0.2f)
                        ),
                        shape = RoundedCornerShape(15.dp),
                        border = CardDefaults.outlinedCardBorder().copy(
                            brush = if (selectedOption == option) 
                                Brush.horizontalGradient(listOf(Color.Blue, Color.Blue))
                            else 
                                Brush.horizontalGradient(listOf(Color.Black, Color.Black))
                        )
                    ) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(12.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = option,
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Medium,
                                color = Color.White,
                                textAlign = TextAlign.Center
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ActivityLevelSection(
    selectedActivity: String,
    onActivitySelected: (String) -> Unit
) {
    val activities = listOf(
        "Sedentary" to "Little to no exercise",
        "Lightly Active" to "Light exercise 1-3 days/week",
        "Moderately Active" to "Moderate exercise 3-5 days/week",
        "Very Active" to "Heavy exercise 6-7 days/week"
    )
    
    Column(
        modifier = Modifier.fillMaxWidth()
    ) {
        Text(
            text = "Activity Level*",
            fontSize = 18.sp,
            fontWeight = FontWeight.Medium,
            color = Color.White,
            modifier = Modifier.padding(bottom = 16.dp)
        )
        
        activities.forEach { (activity, description) ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 8.dp)
                    .selectable(
                        selected = selectedActivity == activity,
                        onClick = { onActivitySelected(activity) }
                    ),
                colors = CardDefaults.cardColors(
                    containerColor = Color.Black.copy(alpha = 0.2f)
                ),
                shape = RoundedCornerShape(15.dp),
                border = CardDefaults.outlinedCardBorder().copy(
                    brush = if (selectedActivity == activity) 
                        Brush.horizontalGradient(listOf(Color.Blue, Color.Blue))
                    else 
                        Brush.horizontalGradient(listOf(Color.Black, Color.Black))
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = if (selectedActivity == activity) 
                            Icons.Default.CheckCircle 
                        else 
                            Icons.Default.RadioButtonUnchecked,
                        contentDescription = null,
                        tint = if (selectedActivity == activity) 
                            Color.Blue 
                        else 
                            Color.White.copy(alpha = 0.6f),
                        modifier = Modifier.size(20.dp)
                    )
                    
                    Spacer(modifier = Modifier.width(12.dp))
                    
                    Column {
                        Text(
                            text = activity,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Medium,
                            color = Color.White
                        )
                        Text(
                            text = description,
                            fontSize = 12.sp,
                            color = Color.White.copy(alpha = 0.6f)
                        )
                    }
                }
            }
        }
    }
}

private suspend fun validateAndCompleteSetup(
    goal: String,
    activityLevel: String,
    macroPreference: String,
    customDietText: String,
    profile: UserProfile?,
    context: android.content.Context,
    onError: (String) -> Unit,
    onLoading: (Boolean) -> Unit,
    onSuccess: () -> Unit
): Boolean {
    if (profile == null) {
        onError("Profile not found. Please complete profile setup first.")
        return false
    }
    
    if (macroPreference == "Custom" && customDietText.trim().isEmpty()) {
        onError("Please describe your custom diet preference.")
        return false
    }
    
    onLoading(true)
    
    try {
        // Calculate calorie goal
        val calorieGoal = calculateCalorieGoal(profile, goal, activityLevel)
        
        // Update profile with goals
        val updatedProfile = profile.copy(
            goal = goal,
            activityLevel = activityLevel,
            macroPreference = macroPreference,
            customDiet = if (macroPreference == "Custom") customDietText.trim() else null
        )
        
        // Save updated profile
        UserProfileRepository.saveProfile(context, updatedProfile)
        
        // You could also save calorie goal separately if needed
        
        onLoading(false)
        onSuccess()
        return true
        
    } catch (e: Exception) {
        onLoading(false)
        onError("Failed to save goals: ${e.message}")
        return false
    }
}

private fun calculateCalorieGoal(
    profile: UserProfile,
    goal: String,
    activityLevel: String
): Double {
    val weight = profile.weight.toDouble()
    val height = profile.height.toDouble()
    val age = profile.age.toDouble()
    
    // Calculate BMR using Mifflin-St Jeor Equation
    val bmr = if (profile.gender == "Male") {
        10 * weight + 6.25 * height - 5 * age + 5
    } else {
        10 * weight + 6.25 * height - 5 * age - 161
    }
    
    // Activity multiplier
    val activityMultiplier = when (activityLevel) {
        "Sedentary" -> 1.2
        "Lightly Active" -> 1.375
        "Moderately Active" -> 1.55
        "Very Active" -> 1.725
        else -> 1.2
    }
    
    // Goal adjustment
    val goalAdjustment = when (goal) {
        "Lose Weight" -> -500
        "Gain Weight" -> 300
        "Build Muscle" -> 300
        else -> 0
    }
    
    return bmr * activityMultiplier + goalAdjustment
}
