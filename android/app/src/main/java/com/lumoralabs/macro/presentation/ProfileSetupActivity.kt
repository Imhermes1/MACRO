package com.lumoralabs.macro.presentation

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
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
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
    var isLoading by remember { mutableStateOf(false) }
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current

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
            .verticalScroll(rememberScrollState())
            .clickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() }
            ) {
                focusManager.clearFocus()
            }
            .padding(32.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(40.dp))
        
        // Centered header
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(
                text = "Complete your profile",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                textAlign = TextAlign.Center
            )
            
            Text(
                text = "We've pre-filled some information from your account",
                fontSize = 14.sp,
                color = Color.White.copy(alpha = 0.8f),
                modifier = Modifier.padding(horizontal = 16.dp),
                textAlign = TextAlign.Center
            )
        }
        
        // Logout button
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.End
        ) {
            TextButton(
                onClick = {
                    com.google.firebase.auth.FirebaseAuth.getInstance().signOut()
                    context.startActivity(Intent(context, LoginActivity::class.java))
                    (context as ComponentActivity).finish()
                }
            ) {
                Text("Logout", color = Color.White.copy(alpha = 0.7f))
            }
        }
        
        StyledTextField(
            value = firstName,
            onValueChange = { firstName = it },
            label = "First Name*",
            focusManager = focusManager
        )
        
        StyledTextField(
            value = lastName,
            onValueChange = { lastName = it },
            label = "Last Name (optional)",
            focusManager = focusManager
        )
        
        StyledTextField(
            value = age,
            onValueChange = { age = it },
            label = "Age*",
            keyboardType = KeyboardType.Number,
            focusManager = focusManager
        )
        
        // DOB field with red exclamation button
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
        ) {
            StyledTextField(
                value = dob,
                onValueChange = { dob = it },
                label = "Date of Birth (optional)",
                keyboardType = KeyboardType.Number,
                focusManager = focusManager,
                modifier = Modifier.weight(1f)
            )
            
            IconButton(
                onClick = { showDobIncentive = !showDobIncentive }
            ) {
                Icon(
                    imageVector = Icons.Default.Warning,
                    contentDescription = "Birthday Info",
                    tint = Color.Red
                )
            }
        }
        
        if (showDobIncentive) {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.1f))
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Birthday Surprise! 🎉",
                        fontWeight = FontWeight.Bold,
                        color = Color.White,
                        fontSize = 16.sp
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "If you provide your Date of Birth, we'll do something special for you on your birthday!",
                        color = Color.White.copy(alpha = 0.9f),
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
        
        StyledTextField(
            value = height,
            onValueChange = { height = it },
            label = "Height (cm)*",
            keyboardType = KeyboardType.Decimal,
            focusManager = focusManager
        )
        
        StyledTextField(
            value = weight,
            onValueChange = { weight = it },
            label = "Weight (kg)*",
            keyboardType = KeyboardType.Decimal,
            focusManager = focusManager
        )
        
        Spacer(modifier = Modifier.height(30.dp))
        
        Button(
            onClick = {
                focusManager.clearFocus() // Clear focus to dismiss keyboard
                
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
                
                isLoading = true
                
                try {
                    val profile = com.lumoralabs.macro.domain.UserProfile(
                        firstName = firstName,
                        lastName = if (lastName.isBlank()) null else lastName,
                        age = ageInt,
                        dob = if (dob.isBlank()) null else dob,
                        height = heightFloat,
                        weight = weightFloat
                    )
                    
                    // Save profile
                    com.lumoralabs.macro.data.UserProfileRepository.saveProfile(context, profile)
                    
                    // Show success message
                    Toast.makeText(context, "Profile saved successfully!", Toast.LENGTH_SHORT).show()
                    
                    // Navigate to main activity after delay
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        // Since height and weight are provided, BMI is complete
                        // Navigate directly to main app
                        val intent = Intent(context, MainActivity::class.java)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                        context.startActivity(intent)
                        (context as ComponentActivity).finish()
                    }, 1000)
                    
                } catch (e: Exception) {
                    Toast.makeText(context, "Error saving profile: ${e.message}", Toast.LENGTH_LONG).show()
                    isLoading = false
                }
                    isLoading = false
                }
            },
            enabled = !isLoading,
            modifier = Modifier
                .fillMaxWidth()
                .height(56.dp),
            shape = RoundedCornerShape(28.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color.White.copy(alpha = 0.2f),
                contentColor = Color.White
            )
        ) {
            Row(
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        color = Color.White,
                        strokeWidth = 2.dp
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                }
                Text(
                    text = if (isLoading) "Saving..." else "Save Profile",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium
                )
            }
        }
    }
}

@Composable
fun StyledTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    keyboardType: KeyboardType = KeyboardType.Text,
    focusManager: androidx.compose.ui.focus.FocusManager,
    modifier: Modifier = Modifier
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label, color = Color.White) },
        modifier = modifier.fillMaxWidth(),
        keyboardOptions = KeyboardOptions(
            keyboardType = keyboardType,
            imeAction = ImeAction.Done
        ),
        keyboardActions = KeyboardActions(
            onDone = {
                focusManager.clearFocus()
            }
        ),
        colors = OutlinedTextFieldDefaults.colors(
            focusedTextColor = Color.White,
            unfocusedTextColor = Color.White,
            focusedBorderColor = Color.White.copy(alpha = 0.7f),
            unfocusedBorderColor = Color.White.copy(alpha = 0.5f)
        ),
        shape = RoundedCornerShape(15.dp)
    )
}
