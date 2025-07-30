import Foundation

class ICloudService {
    func saveGroup(_ group: Group) {
        // Example: Save group to iCloud using NSUbiquitousKeyValueStore
        let store = NSUbiquitousKeyValueStore.default
        store.set(["id": group.id, "name": group.name, "members": group.members], forKey: group.id)
        store.synchronize()
    }

    func getGroup(id: String) -> Group? {
        let store = NSUbiquitousKeyValueStore.default
        guard let data = store.dictionary(forKey: id),
              let name = data["name"] as? String,
              let members = data["members"] as? [String] else { return nil }
        return Group(id: id, name: name, members: members)
    }
}
