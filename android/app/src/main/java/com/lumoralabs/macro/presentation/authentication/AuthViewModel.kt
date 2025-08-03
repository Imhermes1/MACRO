package com.lumoralabs.macro.presentation.authentication

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.auth.Auth
import io.github.jan.supabase.auth.Session
import io.github.jan.supabase.postgrest.Postgrest
import io.github.jan.supabase.postgrest.from
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class AuthViewModel(
    private val supabase: io.github.jan.supabase.SupabaseClient = createSupabaseClient(
        supabaseUrl = "https://macro.supabase.co",
        supabaseKey = "sb_publishable_BqTi3dfSgQj6bwQEqqaYuw_-tKblmsF"
    ) {
        install(Postgrest)
        install(Auth)
    }
) : ViewModel() {
    private val auth = supabase.auth
    private val _session = MutableStateFlow<Session?>(null)
    val session: StateFlow<Session?> = _session.asStateFlow()

    fun signUp(email: String, password: String) = viewModelScope.launch {
        try {
            val authResponse = auth.signUp(email, password)
            createProfile(authResponse.user.id)
        } catch (e: Exception) {
            // Handle signup errors
        }
    }

    fun signIn(email: String, password: String) = viewModelScope.launch {
        try {
            val authResponse = auth.signInWithPassword(email, password)
            _session.value = authResponse.session
        } catch (e: Exception) {
            // Handle login errors
        }
    }

    private suspend fun createProfile(userId: String) {
        supabase.from("profiles")
            .insert(mapOf(
                "user_id" to userId,
                "username" to "user_${userId.take(8)}"
            ))
    }

    fun signOut() = viewModelScope.launch {
        auth.signOut()
        _session.value = null
    }

    companion object {
        fun createSupabaseClient() = createSupabaseClient(
            supabaseUrl = "https://macro.supabase.co",
            supabaseKey = "sb_publishable_BqTi3dfSgQj6bwQEqqaYuw_-tKblmsF"
        ) {
            install(Postgrest)
            install(Auth)
        }
    }
}
