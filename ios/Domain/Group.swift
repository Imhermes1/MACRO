import Foundation

// Basic Group data model conforming to required protocols for Supabase
public struct Group: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let members: [String]
    
    // Add CodingKeys for proper JSON serialization with Supabase
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case members
    }
}
