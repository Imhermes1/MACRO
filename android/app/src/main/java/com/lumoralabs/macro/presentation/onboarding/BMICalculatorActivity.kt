package com.lumoralabs.macro.presentation.onboarding

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme

class BMICalculatorActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MacroTheme {
                UniversalBackground {
                    BMICalculatorScreen()
                }
            }
        }
    }
}

@Composable
fun BMICalculatorScreen() {
    var height by remember { mutableStateOf("") }
    var weight by remember { mutableStateOf("") }
    var bmi by remember { mutableStateOf(0.0) }
    var bmr by remember { mutableStateOf(0.0) }
    var calorieGoal by remember { mutableStateOf(0.0) }
    var age by remember { mutableStateOf("") }
    var gender by remember { mutableStateOf("Male") }
    var activityLevel by remember { mutableStateOf("Sedentary") }
    var goal by remember { mutableStateOf("Maintain Weight") }
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current

    // Auto-populate fields from saved profile data
    LaunchedEffect(Unit) {
        val profile = com.lumoralabs.macro.data.UserProfileRepository.loadProfile(context)
        if (profile != null) {
            if (height.isEmpty() && profile.height > 0) {
                height = profile.height.toString()
            }
            if (weight.isEmpty() && profile.weight > 0) {
                weight = profile.weight.toString()
            }
            if (age.isEmpty() && profile.age > 0) {
                age = profile.age.toString()
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .clickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() }
            ) {
                focusManager.clearFocus()
            }
            .padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "BMI & Calorie Calculator",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
        
        Spacer(modifier = Modifier.height(30.dp))
        
        OutlinedTextField(
            value = height,
            onValueChange = { height = it },
            label = { Text("Height (cm)", color = Color.White) },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White,
                focusedBorderColor = Color.White.copy(alpha = 0.7f),
                unfocusedBorderColor = Color.White.copy(alpha = 0.5f)
            ),
            shape = RoundedCornerShape(15.dp)
        )
        
        Spacer(modifier = Modifier.height(15.dp))
        
        OutlinedTextField(
            value = weight,
            onValueChange = { weight = it },
            label = { Text("Weight (kg)", color = Color.White) },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White,
                focusedBorderColor = Color.White.copy(alpha = 0.7f),
                unfocusedBorderColor = Color.White.copy(alpha = 0.5f)
            ),
            shape = RoundedCornerShape(15.dp)
        )
        
        Spacer(modifier = Modifier.height(15.dp))
        
        OutlinedTextField(
            value = age,
            onValueChange = { age = it },
            label = { Text("Age", color = Color.White) },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White,
                focusedBorderColor = Color.White.copy(alpha = 0.7f),
                unfocusedBorderColor = Color.White.copy(alpha = 0.5f)
            ),
            shape = RoundedCornerShape(15.dp)
        )
        
        Spacer(modifier = Modifier.height(30.dp))
        
        Button(
            onClick = {
                val h = height.toDoubleOrNull()?.div(100) ?: 0.0
                val w = weight.toDoubleOrNull() ?: 0.0
                val a = age.toIntOrNull() ?: 0
                bmi = if (h > 0) w / (h * h) else 0.0
                bmr = if (gender == "Male") {
                    10 * w + 6.25 * (h * 100) - 5 * a + 5
                } else {
                    10 * w + 6.25 * (h * 100) - 5 * a - 161
                }
                val activityMultiplier = when (activityLevel) {
                    "Sedentary" -> 1.2
                    "Lightly Active" -> 1.375
                    "Moderately Active" -> 1.55
                    "Very Active" -> 1.725
                    else -> 1.2
                }
                var goalAdjustment = 0.0
                when (goal) {
                    "Lose Weight" -> goalAdjustment = -500.0
                    "Gain Muscle" -> goalAdjustment = 300.0
                    "Maintain Weight" -> goalAdjustment = 0.0
                }
                calorieGoal = bmr * activityMultiplier + goalAdjustment

                val profile = com.lumoralabs.macro.data.UserProfileRepository.loadProfile(context)
                if (profile != null) {
                    val updatedProfile = profile.copy(
                        height = (h * 100).toFloat(), // Convert back to cm for storage
                        weight = w.toFloat()
                    )
                    com.lumoralabs.macro.data.UserProfileRepository.saveProfile(context, updatedProfile)
                    Toast.makeText(context, "BMI and calorie goal saved!", Toast.LENGTH_SHORT).show()
                    val intent = Intent(context, com.lumoralabs.macro.MainActivity::class.java)
                    context.startActivity(intent)
                    (context as ComponentActivity).finish()
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            shape = RoundedCornerShape(28.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color.White.copy(alpha = 0.2f),
                contentColor = Color.White
            )
        ) {
            Text(
                text = "Calculate & Save",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium
            )
        }
        
        Spacer(modifier = Modifier.height(30.dp))
        
        Text(
            text = "BMI: %.2f".format(bmi),
            fontSize = 18.sp,
            color = Color.White,
            fontWeight = FontWeight.Medium
        )
        
        Text(
            text = "Recommended Calories: %.0f".format(calorieGoal),
            fontSize = 18.sp,
            color = Color.White,
            fontWeight = FontWeight.Medium
        )
    }
}
