package com.lumoralabs.macro.presentation

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

class BMICalculatorActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            BMICalculatorScreen()
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

    Column(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("BMI & Calorie Calculator", style = MaterialTheme.typography.headlineMedium)
        Spacer(modifier = Modifier.height(24.dp))
        OutlinedTextField(value = height, onValueChange = { height = it }, label = { Text("Height (cm)") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = weight, onValueChange = { weight = it }, label = { Text("Weight (kg)") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = age, onValueChange = { age = it }, label = { Text("Age") })
        Spacer(modifier = Modifier.height(8.dp))
        Row {
            Text("Gender:")
            Spacer(modifier = Modifier.width(8.dp))
            DropdownMenu(expanded = true, onDismissRequest = {}, modifier = Modifier.width(120.dp)) {
                DropdownMenuItem(onClick = { gender = "Male" }, text = { Text("Male") })
                DropdownMenuItem(onClick = { gender = "Female" }, text = { Text("Female") })
            }
        }
        Spacer(modifier = Modifier.height(8.dp))
        Row {
            Text("Activity Level:")
            Spacer(modifier = Modifier.width(8.dp))
            DropdownMenu(expanded = true, onDismissRequest = {}, modifier = Modifier.width(180.dp)) {
                DropdownMenuItem(onClick = { activityLevel = "Sedentary" }, text = { Text("Sedentary") })
                DropdownMenuItem(onClick = { activityLevel = "Lightly Active" }, text = { Text("Lightly Active") })
                DropdownMenuItem(onClick = { activityLevel = "Moderately Active" }, text = { Text("Moderately Active") })
                DropdownMenuItem(onClick = { activityLevel = "Very Active" }, text = { Text("Very Active") })
            }
        }
        Spacer(modifier = Modifier.height(8.dp))
        Row {
            Text("Goal:")
            Spacer(modifier = Modifier.width(8.dp))
            DropdownMenu(expanded = true, onDismissRequest = {}, modifier = Modifier.width(180.dp)) {
                DropdownMenuItem(onClick = { goal = "Lose Weight" }, text = { Text("Lose Weight") })
                DropdownMenuItem(onClick = { goal = "Gain Muscle" }, text = { Text("Gain Muscle") })
                DropdownMenuItem(onClick = { goal = "Maintain Weight" }, text = { Text("Maintain Weight") })
            }
        }
        Spacer(modifier = Modifier.height(16.dp))
        val context = LocalContext.current
        Button(onClick = {
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

            // Save calorie goal to user profile
            val profile = com.lumoralabs.macro.data.UserProfileRepository.loadProfile(context)
            if (profile != null) {
                val updatedProfile = profile.copy(
                    height = h.toFloat(),
                    weight = w.toFloat()
                )
                com.lumoralabs.macro.data.UserProfileRepository.saveProfile(context, updatedProfile)
                Toast.makeText(context, "Calorie goal saved to profile!", Toast.LENGTH_SHORT).show()
            }
        }) {
            Text("Calculate & Save")
        }
        Spacer(modifier = Modifier.height(16.dp))
        Text("BMI: %.2f".format(bmi))
        Text("Recommended Calories: %.0f".format(calorieGoal))
    }
}
