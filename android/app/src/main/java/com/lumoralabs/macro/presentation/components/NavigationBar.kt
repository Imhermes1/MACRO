package com.lumoralabs.macro.presentation.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@Composable
fun NavigationBar(
    showRightButton: Boolean = false,
    onLeftClick: () -> Unit = {},
    onRightClick: () -> Unit = {}
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(MaterialTheme.colors.surface.copy(alpha = 0.6f), RoundedCornerShape(50))
            .padding(horizontal = 8.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Left navigation button
        IconButton(
            onClick = onLeftClick,
            modifier = Modifier
                .background(MaterialTheme.colors.surface.copy(alpha = 0.8f), CircleShape)
        ) {
            Icon(Icons.Default.ArrowBack, contentDescription = "Back")
        }

        Spacer(modifier = Modifier.weight(1f))

        // Center title
        Text(
            text = "Macro by the Moral Labs",
            style = MaterialTheme.typography.h6,
            modifier = Modifier
                .background(MaterialTheme.colors.surface.copy(alpha = 0.8f), RoundedCornerShape(50))
                .padding(horizontal = 16.dp, vertical = 8.dp)
        )

        Spacer(modifier = Modifier.weight(1f))

        // Right button (invisible if not shown)
        if (showRightButton) {
            IconButton(
                onClick = onRightClick,
                modifier = Modifier
                    .background(MaterialTheme.colors.surface.copy(alpha = 0.8f), CircleShape)
            ) {
                Icon(Icons.Default.MoreVert, contentDescription = "More")
            }
        } else {
            Spacer(modifier = Modifier.size(44.dp))
        }
    }
}
