import Foundation
import FirebaseFirestore

class FirebaseService {
    private let db = Firestore.firestore()

    func saveGroup(_ group: Group) {
        let data: [String: Any] = [
            "id": group.id,
            "name": group.name,
            "members": group.members
        ]
        db.collection("groups").document(group.id).setData(data)
    }

    func getGroups(completion: @escaping ([Group]) -> Void) {
        db.collection("groups").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            let groups = documents.compactMap { doc -> Group? in
                let data = doc.data()
                guard let id = data["id"] as? String,
                      let name = data["name"] as? String,
                      let members = data["members"] as? [String] else { return nil }
                return Group(id: id, name: name, members: members)
            }
            completion(groups)
        }
    }
}
