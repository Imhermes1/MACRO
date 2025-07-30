package com.lumoralabs.macro.presentation

import androidx.compose.runtime.Composable
import androidx.compose.material3.Text
import androidx.compose.foundation.layout.Column
import androidx.compose.ui.Modifier

@Composable
fun SettingsMenu() {
    Column(modifier = Modifier) {
        Text("Profile")
        Text("Notifications")
        Text("Privacy")
        Text("About")
    }
}
