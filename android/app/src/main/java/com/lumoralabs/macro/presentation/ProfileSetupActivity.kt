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

class ProfileSetupActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ProfileSetupScreen()
        }
    }
}

@Composable
fun ProfileSetupScreen() {
    var firstName by remember { mutableStateOf("") }
    var lastName by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var dob by remember { mutableStateOf("") }
    var height by remember { mutableStateOf("") }
    var weight by remember { mutableStateOf("") }
    var showDobIncentive by remember { mutableStateOf(false) }
    val context = LocalContext.current

    Column(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("Set up your profile", style = MaterialTheme.typography.headlineMedium)
        Spacer(modifier = Modifier.height(24.dp))
        OutlinedTextField(value = firstName, onValueChange = { firstName = it }, label = { Text("First Name*") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = lastName, onValueChange = { lastName = it }, label = { Text("Last Name (optional)") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = age, onValueChange = { age = it }, label = { Text("Age*") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = dob, onValueChange = { dob = it; showDobIncentive = true }, label = { Text("Date of Birth (optional)") })
        if (showDobIncentive) {
            Text("Provide your DOB for personalized insights and rewards!", color = MaterialTheme.colorScheme.primary)
        }
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = height, onValueChange = { height = it }, label = { Text("Height*") })
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedTextField(value = weight, onValueChange = { weight = it }, label = { Text("Weight*") })
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = {
            if (firstName.isBlank() || age.isBlank() || height.isBlank() || weight.isBlank()) {
                Toast.makeText(context, "Please fill in all required fields.", Toast.LENGTH_SHORT).show()
                return@Button
            }
            val ageInt = age.toIntOrNull()
            val heightFloat = height.toFloatOrNull()
            val weightFloat = weight.toFloatOrNull()
            if (ageInt == null || heightFloat == null || weightFloat == null) {
                Toast.makeText(context, "Please enter valid numbers for age, height, and weight.", Toast.LENGTH_SHORT).show()
                return@Button
            }
            val profile = com.lumoralabs.macro.domain.UserProfile(
                firstName = firstName,
                lastName = if (lastName.isBlank()) null else lastName,
                age = ageInt,
                dob = if (dob.isBlank()) null else dob,
                height = heightFloat,
                weight = weightFloat
            )
            com.lumoralabs.macro.data.UserProfileRepository.saveProfile(context, profile)
            com.lumoralabs.macro.data.FirebaseService.saveGroup(
                com.lumoralabs.macro.domain.Group(
                    id = "profile_${firstName}",
                    name = firstName,
                    members = listOf(firstName)
                )
            )
            Toast.makeText(context, "Profile saved and synced!", Toast.LENGTH_SHORT).show()
        }) {
            Text("Save Profile")
        }
    }
}
