import Foundation

class iCloudDocumentService {
    static let shared = iCloudDocumentService()
    
    private var documentsURL: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    private init() {}
    
    // MARK: - iCloud Availability Check
    
    func isiCloudAvailable() -> Bool {
        return documentsURL != nil
    }
    
    // MARK: - Document Operations
    
    func saveProfile(_ profile: UserProfile, completion: @escaping (Bool) -> Void) {
        guard let documentsURL = documentsURL else {
            completion(false)
            return
        }
        
        DispatchQueue.global(qos: .utility).async {
            do {
                // Create documents directory if it doesn't exist
                try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
                
                // Create profile file URL
                let profileURL = documentsURL.appendingPathComponent("UserProfile.json")
                
                // Encode profile to JSON
                let encoder = JSONEncoder()
                let profileData = try encoder.encode(profile)
                
                // Write to iCloud Documents
                try profileData.write(to: profileURL)
                
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func loadProfile(completion: @escaping (UserProfile?) -> Void) {
        guard let documentsURL = documentsURL else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .utility).async {
            do {
                let profileURL = documentsURL.appendingPathComponent("UserProfile.json")
                
                guard FileManager.default.fileExists(atPath: profileURL.path) else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                let profileData = try Data(contentsOf: profileURL)
                let decoder = JSONDecoder()
                let profile = try decoder.decode(UserProfile.self, from: profileData)
                
                DispatchQueue.main.async {
                    completion(profile)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

// MARK: - UserProfile Codable Extension

extension UserProfile: Codable {
    enum CodingKeys: String, CodingKey {
        case firstName, lastName, age, height, weight, dob
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        age = try container.decode(Int.self, forKey: .age)
        height = try container.decode(Float.self, forKey: .height)
        weight = try container.decode(Float.self, forKey: .weight)
        dob = try container.decodeIfPresent(Date.self, forKey: .dob)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encode(age, forKey: .age)
        try container.encode(height, forKey: .height)
        try container.encode(weight, forKey: .weight)
        try container.encodeIfPresent(dob, forKey: .dob)
    }
}
