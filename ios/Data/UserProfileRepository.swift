import Foundation

class UserProfileRepository {
    private let key = "user_profile"
    private let defaults = UserDefaults.standard

    func saveProfile(_ profile: UserProfile) {
        let dict: [String: Any] = [
            "firstName": profile.firstName,
            "lastName": profile.lastName as Any,
            "age": profile.age,
            "dob": profile.dob as Any,
            "height": profile.height,
            "weight": profile.weight
        ]
        defaults.set(dict, forKey: key)
    }

    func loadProfile() -> UserProfile? {
        guard let dict = defaults.dictionary(forKey: key) else { return nil }
        guard let firstName = dict["firstName"] as? String,
              let age = dict["age"] as? Int,
              let height = dict["height"] as? Float,
              let weight = dict["weight"] as? Float else { return nil }
        let lastName = dict["lastName"] as? String
        let dob = dict["dob"] as? String
        return UserProfile(firstName: firstName, lastName: lastName, age: age, dob: dob, height: height, weight: weight)
    }
}
