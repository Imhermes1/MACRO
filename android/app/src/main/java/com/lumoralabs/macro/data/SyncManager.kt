package com.lumoralabs.macro.data

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities

object SyncManager {
    fun isOnline(context: Context): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = cm.activeNetwork ?: return false
        val capabilities = cm.getNetworkCapabilities(network) ?: return false
        return capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }

    fun syncGroups(context: Context) {
        if (isOnline(context)) {
            val localGroups = LocalGroupStorage.loadGroups(context)
            localGroups.forEach { FirebaseService.saveGroup(it) }
            FirebaseService.getGroups { cloudGroups ->
                LocalGroupStorage.saveGroups(context, cloudGroups)
            }
        }
    }
}
