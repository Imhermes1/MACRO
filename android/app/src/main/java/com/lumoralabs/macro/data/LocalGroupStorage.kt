package com.lumoralabs.macro.data

import android.content.Context
import android.content.SharedPreferences
import com.lumoralabs.macro.domain.Group
import org.json.JSONArray
import org.json.JSONObject

object LocalGroupStorage {
    private const val PREFS_NAME = "group_storage"
    private const val GROUPS_KEY = "groups"

    fun saveGroups(context: Context, groups: List<Group>) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val jsonArray = JSONArray()
        groups.forEach { group ->
            val obj = JSONObject()
            obj.put("id", group.id)
            obj.put("name", group.name)
            obj.put("members", JSONArray(group.members))
            jsonArray.put(obj)
        }
        prefs.edit().putString(GROUPS_KEY, jsonArray.toString()).apply()
    }

    fun loadGroups(context: Context): List<Group> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(GROUPS_KEY, "[]") ?: "[]"
        val jsonArray = JSONArray(json)
        val groups = mutableListOf<Group>()
        for (i in 0 until jsonArray.length()) {
            val obj = jsonArray.getJSONObject(i)
            val id = obj.getString("id")
            val name = obj.getString("name")
            val membersJson = obj.getJSONArray("members")
            val members = List(membersJson.length()) { idx -> membersJson.getString(idx) }
            groups.add(Group(id, name, members))
        }
        return groups
    }
}
