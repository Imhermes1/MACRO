package com.lumoralabs.macro.data

import com.lumoralabs.macro.domain.Group

class GroupRepository {
    private val groups = mutableListOf<Group>()

    fun addGroup(group: Group) {
        groups.add(group)
    }

    fun getGroups(): List<Group> = groups
}
