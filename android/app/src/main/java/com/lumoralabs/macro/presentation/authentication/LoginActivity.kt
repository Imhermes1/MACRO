package com.lumoralabs.macro.presentation.authentication

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.auth.FirebaseAuth
import com.lumoralabs.macro.ui.components.UniversalBackground
import com.lumoralabs.macro.ui.theme.MacroTheme

class LoginActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MacroTheme {
                UniversalBackground {
                    LoginScreen()
                }
            }
        }
    }
}

@Composable
fun LoginScreen() {
    // Email login button only, no fields
    val auth = FirebaseAuth.getInstance()
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Welcome to MACRO",
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
        
    Spacer(modifier = Modifier.height(40.dp))
    // Login Buttons
    PillButton(
        text = "Login with Email",
        icon = Icons.Default.Email,
        onClick = {
            // TODO: Show email login dialog/modal
                            if (profile == null) {
                                val intent = Intent(context, ProfileSetupActivity::class.java)
                                context.startActivity(intent)
                            } else {
                                val intent = Intent(context, com.lumoralabs.macro.MainActivity::class.java)
                                context.startActivity(intent)
                            }
                        } else {
                            Toast.makeText(context, "Login failed!", Toast.LENGTH_SHORT).show()
                        }
                    }
            }
        )
        
        Spacer(modifier = Modifier.height(15.dp))
        
        PillButton(
            text = "Login Anonymously (Demo)",
            icon = Icons.Default.Person,
            onClick = {
                auth.signInAnonymously()
                    .addOnCompleteListener { task ->
                        if (task.isSuccessful) {
                            // For demo purposes, simulate user profile data
                            val user = auth.currentUser
                            val profileUpdates = com.google.firebase.auth.UserProfileChangeRequest.Builder()
                                .setDisplayName("Demo User")
                                .build()
                            user?.updateProfile(profileUpdates)
                            
                            val profile = com.lumoralabs.macro.data.UserProfileRepository.loadProfile(context)
                            if (profile == null) {
                                val intent = Intent(context, ProfileSetupActivity::class.java)
                                context.startActivity(intent)
                            } else {
                                val intent = Intent(context, com.lumoralabs.macro.MainActivity::class.java)
                                context.startActivity(intent)
                            }
                        } else {
                            Toast.makeText(context, "Anonymous login failed!", Toast.LENGTH_SHORT).show()
                        }
                    }
            }
        )
        
        Spacer(modifier = Modifier.height(15.dp))
        
        PillButton(
            text = "Login with Google",
            icon = Icons.Default.AccountCircle,
            onClick = {
                // TODO: Implement Google login
                Toast.makeText(context, "Google login not implemented yet", Toast.LENGTH_SHORT).show()
            }
        )
    }
}

@Composable
fun PillButton(
    text: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    Button(
        onClick = onClick,
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
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = text,
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium
            )
        }
    }
}
