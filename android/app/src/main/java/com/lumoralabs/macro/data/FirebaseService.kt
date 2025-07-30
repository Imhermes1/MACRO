package com.lumoralabs.macro.data

import com.google.firebase.firestore.FirebaseFirestore

object FirebaseService {
    private val db = FirebaseFirestore.getInstance()

    fun saveGroup(group: Group) {
        db.collection("groups").document(group.id).set(group)
    }

    fun getGroups(onResult: (List<Group>) -> Unit) {
        db.collection("groups").get().addOnSuccessListener { result ->
            val groups = result.documents.mapNotNull { it.toObject(Group::class.java) }
            onResult(groups)
        }
    }
}
