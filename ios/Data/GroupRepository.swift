import Foundation

class GroupRepository {
    private var groups: [Group] = []

    func addGroup(_ group: Group) {
        groups.append(group)
    }

    func getGroups() -> [Group] {
        return groups
    }
}
