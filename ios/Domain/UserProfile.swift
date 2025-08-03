// This is the canonical UserProfile model. Do not redefine elsewhere.
import Foundation

public struct UserProfile: Codable, Identifiable, Sendable {
    public let id: String
    public var firstName: String
    public var lastName: String?
    public var age: Int
    public var dob: String?
    public var height: Float
    public var weight: Float
    
    // Add initializer that creates a UUID for new profiles
    public init(firstName: String, lastName: String? = nil, age: Int, dob: String? = nil, height: Float, weight: Float, id: String = UUID().uuidString) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.dob = dob
        self.height = height
        self.weight = weight
    }
    
    // Add CodingKeys for proper JSON serialization with Supabase
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case age
        case dob = "date_of_birth"
        case height
        case weight
    }
}
