import Foundation

class LocalGroupStorage {
    private let key = "groups"
    private let defaults = UserDefaults.standard

    func saveGroups(_ groups: [Group]) {
        let array = groups.map { ["id": $0.id, "name": $0.name, "members": $0.members] }
        defaults.set(array, forKey: key)
    }

    func loadGroups() -> [Group] {
        guard let array = defaults.array(forKey: key) as? [[String: Any]] else { return [] }
        return array.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let name = dict["name"] as? String,
                  let members = dict["members"] as? [String] else { return nil }
            return Group(id: id, name: name, members: members)
        }
    }
}
