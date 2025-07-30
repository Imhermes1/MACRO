package com.lumoralabs.macro.presentation

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme

class ProfileSetupActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MacroTheme {
                UniversalBackground {
                    ProfileSetupScreen()
                }
            }
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

    // Auto-populate from Firebase Auth
    LaunchedEffect(Unit) {
        val currentUser = com.google.firebase.auth.FirebaseAuth.getInstance().currentUser
        currentUser?.let { user ->
            user.displayName?.let { displayName ->
                val nameParts = displayName.split(" ")
                if (nameParts.isNotEmpty() && firstName.isEmpty()) {
                    firstName = nameParts[0]
                }
                if (nameParts.size > 1 && lastName.isEmpty()) {
                    lastName = nameParts.drop(1).joinToString(" ")
                }
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Complete your profile",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
        
        Text(
            text = "We've pre-filled some information from your account",
            fontSize = 14.sp,
            color = Color.White.copy(alpha = 0.8f),
            modifier = Modifier.padding(horizontal = 16.dp),
            textAlign = TextAlign.Center
        )
        
        Spacer(modifier = Modifier.height(30.dp))
        
        StyledTextField(
            value = firstName,
            onValueChange = { firstName = it },
            label = "First Name*"
        )
        
        Spacer(modifier = Modifier.height(15.dp))
        
        StyledTextField(
            value = lastName,
            onValueChange = { lastName = it },
            label = "Last Name (optional)"
        )
        
        Spacer(modifier = Modifier.height(15.dp))
        
        StyledTextField(
            value = age,
            onValueChange = { age = it },
            label = "Age*",
            keyboardType = KeyboardType.Number
        )
        
        Spacer(modifier = Modifier.height(15.dp))
        
        StyledTextField(
            value = dob,
            onValueChange = { 
                dob = it
                showDobIncentive = it.isNotEmpty()
            },
            label = "Date of Birth (optional)",
            keyboardType = KeyboardType.Number
        )
        
        if (showDobIncentive) {
            Text(
                text = "Provide your DOB for personalized insights and rewards!",
                color = Color.White.copy(alpha = 0.8f),
                fontSize = 14.sp
            )
        }
        
        Spacer(modifier = Modifier.height(15.dp))
        
        StyledTextField(
            value = height,
            onValueChange = { height = it },
            label = "Height (cm)*",
            keyboardType = KeyboardType.Decimal
        )
        
        Spacer(modifier = Modifier.height(15.dp))
        
        StyledTextField(
            value = weight,
            onValueChange = { weight = it },
            label = "Weight (kg)*",
            keyboardType = KeyboardType.Decimal
        )
        
        Spacer(modifier = Modifier.height(30.dp))
        
        Button(
            onClick = {
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
                val intent = Intent(context, BMICalculatorActivity::class.java)
                context.startActivity(intent)
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
                text = "Save Profile",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium
            )
        }
    }
}

@Composable
fun StyledTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    keyboardType: KeyboardType = KeyboardType.Text
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label, color = Color.White) },
        modifier = Modifier.fillMaxWidth(),
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        colors = OutlinedTextFieldDefaults.colors(
            focusedTextColor = Color.White,
            unfocusedTextColor = Color.White,
            focusedBorderColor = Color.White.copy(alpha = 0.7f),
            unfocusedBorderColor = Color.White.copy(alpha = 0.5f)
        ),
        shape = RoundedCornerShape(15.dp)
    )
}
