import Foundation
import CloudKit

class CloudKitProfileService {
    private let container: CKContainer
    private let database: CKDatabase
    
    init() {
        // Use the same container identifier as the authentication service
        self.container = CKContainer(identifier: "iCloud.com.lumoralabs.macro")
        self.database = container.privateCloudDatabase
    }
    
    // MARK: - Profile Operations
    
    func saveProfile(_ profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        // Check account status first
        container.accountStatus { [weak self] status, error in
            guard status == .available else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitProfileError.accountNotAvailable))
                }
                return
            }
            
            self?.performSaveProfile(profile, completion: completion)
        }
    }
    
    private func performSaveProfile(_ profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        let record = CKRecord(recordType: "UserProfile", recordID: CKRecord.ID(recordName: "currentUser"))
        
        record["firstName"] = profile.firstName as CKRecordValue
        record["age"] = profile.age as CKRecordValue
        record["height"] = profile.height as CKRecordValue
        record["weight"] = profile.weight as CKRecordValue
        
        if let lastName = profile.lastName {
            record["lastName"] = lastName as CKRecordValue
        }
        
        if let dob = profile.dob {
            record["dob"] = dob as CKRecordValue
        }
        
        record["lastModified"] = Date() as CKRecordValue
        record["deviceIdentifier"] = CKRecord.ID(recordName: "currentUser").recordName as CKRecordValue
        
        database.save(record) { (savedRecord, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func loadProfile(completion: @escaping (Result<UserProfile?, Error>) -> Void) {
        // Check account status first
        container.accountStatus { [weak self] status, error in
            guard status == .available else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitProfileError.accountNotAvailable))
                }
                return
            }
            
            self?.performLoadProfile(completion: completion)
        }
    }
    
    private func performLoadProfile(completion: @escaping (Result<UserProfile?, Error>) -> Void) {
        let recordID = CKRecord.ID(recordName: "currentUser")
        
        database.fetch(withRecordID: recordID) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    if let ckError = error as? CKError, ckError.code == .unknownItem {
                        // No profile exists in CloudKit yet
                        completion(.success(nil))
                    } else {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let record = record else {
                    completion(.success(nil))
                    return
                }
                
                // Extract profile data from CloudKit record
                guard let firstName = record["firstName"] as? String,
                      let age = record["age"] as? Int,
                      let height = record["height"] as? Float,
                      let weight = record["weight"] as? Float else {
                    completion(.failure(CloudKitProfileError.invalidData))
                    return
                }
                
                let lastName = record["lastName"] as? String
                let dob = record["dob"] as? String
                
                let profile = UserProfile(
                    firstName: firstName,
                    lastName: lastName,
                    age: age,
                    dob: dob,
                    height: height,
                    weight: weight
                )
                
                completion(.success(profile))
            }
        }
    }
    
    // MARK: - Account Status Check
    
    func checkAccountStatus(completion: @escaping (CKAccountStatus) -> Void) {
        container.accountStatus { (status, error) in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
    
    // MARK: - Sync Status
    
    func isCloudKitAvailable(completion: @escaping (Bool) -> Void) {
        checkAccountStatus { status in
            completion(status == .available)
        }
    }
    
    // MARK: - Delete Operations
    
    func deleteProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        let recordID = CKRecord.ID(recordName: "currentUser")
        
        database.delete(withRecordID: recordID) { deletedRecordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

// MARK: - Error Types

enum CloudKitProfileError: LocalizedError {
    case invalidData
    case accountNotAvailable
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Profile data is corrupted or invalid"
        case .accountNotAvailable:
            return "iCloud account is not available. Please sign in to iCloud in Settings."
        case .networkUnavailable:
            return "Network connection is required for cloud sync"
        }
    }
}
