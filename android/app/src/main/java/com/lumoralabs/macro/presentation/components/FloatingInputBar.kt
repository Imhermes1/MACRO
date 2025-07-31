package com.lumoralabs.macro.presentation.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.CameraAlt
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.Alignment

@Composable
fun FloatingInputBar() {
    var text by remember { mutableStateOf("") }
    var isRecording by remember { mutableStateOf(false) }
    var recognizedWords by remember { mutableStateOf(0) }
    val infiniteTransition = rememberInfiniteTransition()
    val animatedScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(600, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        )
    )
    Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
        if (isRecording) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp + (recognizedWords * 4).dp)
                    .scale(animatedScale)
                    .clip(RoundedCornerShape(50))
                    .background(
                        Brush.horizontalGradient(
                            colors = listOf(
                                Color.Red, Color.Yellow, Color.Green, Color.Cyan, Color.Blue, Color.Magenta, Color.Red
                            )
                        )
                    )
                    .alpha(0.5f)
            )
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .clip(RoundedCornerShape(50))
                .background(MaterialTheme.colors.surface.copy(alpha = 0.8f))
                .padding(12.dp)
                .shadow(8.dp, RoundedCornerShape(50)),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = { /* Plus action */ }) {
                Icon(Icons.Default.Add, contentDescription = "Add")
            }
            TextField(
                value = text,
                onValueChange = { text = it },
                placeholder = { Text("Enter calories...") },
                modifier = Modifier.weight(1f),
                colors = TextFieldDefaults.textFieldColors(backgroundColor = Color.Transparent)
            )
            IconButton(onClick = {
                isRecording = !isRecording
                if (isRecording) {
                    recognizedWords = 0 // Reset for demo
                    // Start recording and recognition logic here
                } else {
                    // Stop recording logic here
                }
            }) {
                Icon(
                    Icons.Default.Mic,
                    contentDescription = "Mic",
                    tint = if (isRecording) MaterialTheme.colors.primary else LocalContentColor.current
                )
            }
            IconButton(onClick = { /* Camera action */ }) {
                Icon(Icons.Default.CameraAlt, contentDescription = "Camera")
            }
        }
    }
}
