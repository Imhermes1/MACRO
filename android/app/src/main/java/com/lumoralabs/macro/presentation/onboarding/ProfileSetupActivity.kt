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
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusDirection
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat
import com.lumoralabs.macro.data.UserProfileRepository
import com.lumoralabs.macro.domain.UserProfile
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme
import kotlinx.coroutines.launch

class ProfileSetupActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
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
    var showAlert by remember { mutableStateOf(false) }
    var alertMessage by remember { mutableStateOf("") }
    var hasPrefilledData by remember { mutableStateOf(false) }
    
    val context = LocalContext.current
    val focusManager = LocalFocusManager.current
    val coroutineScope = rememberCoroutineScope()
    val profileRepo = remember { UserProfileRepository(context) }

    // Auto-populate from Firebase Auth
    LaunchedEffect(Unit) {
        val currentUser = com.google.firebase.auth.FirebaseAuth.getInstance().currentUser
        currentUser?.let { user ->
            user.displayName?.let { displayName ->
                val nameParts = displayName.split(" ")
                if (nameParts.isNotEmpty() && firstName.isEmpty()) {
                    firstName = nameParts[0]
                    hasPrefilledData = true
                }
                if (nameParts.size > 1 && lastName.isEmpty()) {
                    lastName = nameParts.drop(1).joinToString(" ")
                    hasPrefilledData = true
                }
            }
        }
    }

    fun isFormValid(): Boolean {
        return firstName.trim().isNotEmpty() &&
               age.trim().isNotEmpty() &&
               height.trim().isNotEmpty() &&
               weight.trim().isNotEmpty()
    }

    fun saveProfile() {
        focusManager.clearFocus()
        
        val trimmedFirstName = firstName.trim()
        val trimmedAge = age.trim()
        val trimmedHeight = height.trim()
        val trimmedWeight = weight.trim()
        val trimmedDob = dob.trim()
        
        // Validate required fields
        if (!isFormValid()) {
            alertMessage = "Please fill in all required fields (marked with *)."
            showAlert = true
            return
        }
        
        // Validate numeric inputs
        val ageInt = trimmedAge.toIntOrNull()
        if (ageInt == null || ageInt <= 0 || ageInt >= 150) {
            alertMessage = "Please enter a valid age between 1 and 149."
            showAlert = true
            return
        }
        
        val heightFloat = trimmedHeight.replace(",", ".").toFloatOrNull()
        if (heightFloat == null || heightFloat <= 0 || heightFloat >= 300) {
            alertMessage = "Please enter a valid height in centimeters (1-299)."
            showAlert = true
            return
        }
        
        val weightFloat = trimmedWeight.replace(",", ".").toFloatOrNull()
        if (weightFloat == null || weightFloat <= 0 || weightFloat >= 1000) {
            alertMessage = "Please enter a valid weight in kilograms (1-999)."
            showAlert = true
            return
        }
        
        // Validate DOB format if provided
        if (trimmedDob.isNotEmpty()) {
            val dobRegex = Regex("^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\\d{4}$")
            if (!dobRegex.matches(trimmedDob)) {
                alertMessage = "Please enter date of birth in DD/MM/YYYY format (e.g., 15/03/1990)."
                showAlert = true
                return
            }
        }
        
        isLoading = true
        
        coroutineScope.launch {
            try {
                val profile = UserProfile(
                    firstName = trimmedFirstName,
                    lastName = if (lastName.trim().isEmpty()) null else lastName.trim(),
                    age = ageInt,
                    dob = if (trimmedDob.isEmpty()) null else trimmedDob,
                    height = heightFloat,
                    weight = weightFloat
                )
                
                profileRepo.saveProfile(profile)
                
                isLoading = false
                alertMessage = "Profile saved successfully! 🎉"
                showAlert = true
                
            } catch (e: Exception) {
                isLoading = false
                alertMessage = "Failed to save profile. Please try again."
                showAlert = true
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(rememberScrollState())
            .clickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() }
            ) {
                focusManager.clearFocus()
            },
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Header with logout button
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Complete Profile",
                fontSize = 28.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            
            TextButton(
                onClick = {
                    com.google.firebase.auth.FirebaseAuth.getInstance().signOut()
                    val intent = Intent(context, LoginActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    context.startActivity(intent)
                }
            ) {
                Text(
                    text = "Logout",
                    color = Color.White.copy(alpha = 0.8f)
                )
            }
        }
        
        if (hasPrefilledData) {
            Text(
                text = "We've pre-filled some information from your account",
                fontSize = 14.sp,
                color = Color.White.copy(alpha = 0.8f),
                textAlign = TextAlign.Center,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp)
            )
        }
        
        // Form fields
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // First Name
            StyledTextField(
                value = firstName,
                onValueChange = { firstName = it },
                placeholder = "First Name*",
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Text,
                    imeAction = ImeAction.Next
                ),
                keyboardActions = KeyboardActions(
                    onNext = { focusManager.moveFocus(FocusDirection.Down) }
                )
            )
            
            // Last Name
            StyledTextField(
                value = lastName,
                onValueChange = { lastName = it },
                placeholder = "Last Name (optional)",
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Text,
                    imeAction = ImeAction.Next
                ),
                keyboardActions = KeyboardActions(
                    onNext = { focusManager.moveFocus(FocusDirection.Down) }
                )
            )
            
            // Age
            StyledTextField(
                value = age,
                onValueChange = { age = it },
                placeholder = "Age*",
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Number,
                    imeAction = ImeAction.Next
                ),
                keyboardActions = KeyboardActions(
                    onNext = { focusManager.moveFocus(FocusDirection.Down) }
                )
            )
            
            // Date of Birth with incentive
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                StyledTextField(
                    value = dob,
                    onValueChange = { dob = it },
                    placeholder = "Date of Birth (DD/MM/YYYY)",
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Number,
                        imeAction = ImeAction.Next
                    ),
                    keyboardActions = KeyboardActions(
                        onNext = { focusManager.moveFocus(FocusDirection.Down) }
                    ),
                    modifier = Modifier.weight(1f)
                )
                
                IconButton(
                    onClick = { showDobIncentive = true }
                ) {
                    Icon(
                        imageVector = Icons.Filled.Warning,
                        contentDescription = "Birthday Info",
                        tint = Color.Red
                    )
                }
            }
            
            // Height
            StyledTextField(
                value = height,
                onValueChange = { height = it },
                placeholder = "Height (cm)*",
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Decimal,
                    imeAction = ImeAction.Next
                ),
                keyboardActions = KeyboardActions(
                    onNext = { focusManager.moveFocus(FocusDirection.Down) }
                )
            )
            
            // Weight
            StyledTextField(
                value = weight,
                onValueChange = { weight = it },
                placeholder = "Weight (kg)*",
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Decimal,
                    imeAction = ImeAction.Done
                ),
                keyboardActions = KeyboardActions(
                    onDone = { focusManager.clearFocus() }
                )
            )
            
            Spacer(modifier = Modifier.height(20.dp))
            
            // Save button
            Button(
                onClick = { saveProfile() },
                enabled = !isLoading && isFormValid(),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                shape = RoundedCornerShape(25.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White.copy(alpha = if (isLoading) 0.1f else 0.2f),
                    contentColor = Color.White
                )
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        color = Color.White,
                        modifier = Modifier.size(20.dp)
                    )
                } else {
                    Text(
                        text = "Save Profile",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(100.dp)) // Extra space for keyboard
        }
    }
    
    // DOB Incentive Dialog
    if (showDobIncentive) {
        AlertDialog(
            onDismissRequest = { showDobIncentive = false },
            title = { Text("Birthday Surprise! 🎉") },
            text = { 
                Text("If you provide your Date of Birth, we'll do something special for you on your birthday!")
            },
            confirmButton = {
                TextButton(onClick = { showDobIncentive = false }) {
                    Text("Got it!")
                }
            }
        )
    }
    
    // Alert Dialog for messages
    if (showAlert) {
        AlertDialog(
            onDismissRequest = { showAlert = false },
            title = { Text("Profile") },
            text = { Text(alertMessage) },
            confirmButton = {
                TextButton(
                    onClick = {
                        showAlert = false
                        if (alertMessage.contains("successfully")) {
                            // Navigate to welcome screen
                            val intent = Intent(context, WelcomeActivity::class.java)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                            context.startActivity(intent)
                        }
                    }
                ) {
                    Text("OK")
                }
            }
        )
    }
}

@Composable
fun StyledTextField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    modifier: Modifier = Modifier,
    keyboardOptions: KeyboardOptions = KeyboardOptions.Default,
    keyboardActions: KeyboardActions = KeyboardActions.Default
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        placeholder = { Text(placeholder, color = Color.White.copy(alpha = 0.7f)) },
        modifier = modifier.fillMaxWidth(),
        keyboardOptions = keyboardOptions,
        keyboardActions = keyboardActions,
        colors = OutlinedTextFieldDefaults.colors(
            focusedTextColor = Color.White,
            unfocusedTextColor = Color.White,
            focusedBorderColor = Color.White.copy(alpha = 0.5f),
            unfocusedBorderColor = Color.White.copy(alpha = 0.3f),
            cursorColor = Color.White
        ),
        shape = RoundedCornerShape(15.dp)
    )
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
                    
                    // Save profile using the new cloud-enabled repository
                    profileRepo.saveProfile(profile)
                    
                    // Show success message
                    Toast.makeText(context, "Profile saved successfully!", Toast.LENGTH_SHORT).show()
                    
                    // Navigate to welcome screen after delay
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                        // Navigate to welcome screen first
                        val intent = Intent(context, WelcomeActivity::class.java)
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
