import Foundation
import Combine

@MainActor
class iCloudDocumentService: ObservableObject {
    static let shared = iCloudDocumentService()
    
    @Published var isAvailable = false
    @Published var lastError: String?
    
    private var documentsURL: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    private init() {
        checkAvailability()
    }
    
    private func checkAvailability() {
        isAvailable = documentsURL != nil
    }
    
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
        
        Task.detached {
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
                
                await MainActor.run {
                    completion(true)
                }
            } catch {
                await MainActor.run {
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
        
        Task.detached {
            do {
                let profileURL = documentsURL.appendingPathComponent("UserProfile.json")
                
                guard FileManager.default.fileExists(atPath: profileURL.path) else {
                    await MainActor.run {
                        completion(nil)
                    }
                    return
                }
                
                let profileData = try Data(contentsOf: profileURL)
                let decoder = JSONDecoder()
                let profile = try decoder.decode(UserProfile.self, from: profileData)
                
                await MainActor.run {
                    completion(profile)
                }
            } catch {
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }
}

