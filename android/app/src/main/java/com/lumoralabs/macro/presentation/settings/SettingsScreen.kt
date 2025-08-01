package com.lumoralabs.macro.presentation.settings

import android.widget.Toast
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.lumoralabs.macro.data.UserProfileRepository

/**
 * SettingsScreen composable for app settings management.
 */

@Composable
fun SettingsScreen(
    onNavigateBack: () -> Unit = {}
) {
    val context = LocalContext.current
    var calorieGoal by remember { mutableStateOf("") }
    val profile = UserProfileRepository.loadProfile(context)
    if (profile != null && calorieGoal.isEmpty()) {
        calorieGoal = profile.weight.toString()
    }
    Column(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        verticalArrangement = Arrangement.Top,
        horizontalAlignment = Alignment.Start
    ) {
        Text("Settings", style = MaterialTheme.typography.headlineMedium)
        Spacer(modifier = Modifier.height(24.dp))
        OutlinedTextField(
            value = calorieGoal,
            onValueChange = { calorieGoal = it },
            label = { Text("Calorie Goal") },
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = {
            if (profile != null) {
                val updatedProfile = profile.copy(weight = calorieGoal.toFloatOrNull() ?: profile.weight)
                UserProfileRepository.saveProfile(context, updatedProfile)
                Toast.makeText(context, "Calorie goal updated!", Toast.LENGTH_SHORT).show()
            }
        }) {
            Text("Save Calorie Goal")
        }
        Spacer(modifier = Modifier.height(32.dp))
        Divider()
        Spacer(modifier = Modifier.height(16.dp))
        Text("Profile", style = MaterialTheme.typography.titleMedium)
        Text("Notifications", style = MaterialTheme.typography.titleMedium)
        Text("Privacy", style = MaterialTheme.typography.titleMedium)
        Text("About", style = MaterialTheme.typography.titleMedium)
    }
}
