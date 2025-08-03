import Foundation
import CloudKit
import Combine

class CloudKitAuthService: ObservableObject {
    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published var isSignedIn: Bool = false
    @Published var userDisplayName: String?
    
    private let container: CKContainer
    
    init() {
        // Use dynamic container identifier that matches bundle ID
        self.container = CKContainer.default()
        checkAccountStatus()
    }
    
    // MARK: - Account Status Check
    
    func checkAccountStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.accountStatus = status
                self?.isSignedIn = (status == .available)
                
                if status == .available {
                    self?.fetchUserDisplayName()
                }
            }
        }
    }
    
    // MARK: - User Information
    
    private func fetchUserDisplayName() {
        container.fetchUserRecordID { [weak self] recordID, error in
            DispatchQueue.main.async {
                if recordID != nil {
                    // For privacy reasons, we'll use a generic display name
                    // instead of fetching the actual user identity
                    self?.userDisplayName = "iCloud User"
                }
            }
        }
    }
    
    // MARK: - Sign In Methods
    
    func signInToiCloud() -> String {
        switch accountStatus {
        case .available:
            return "Already signed in to iCloud"
        case .noAccount:
            return "No iCloud account found. Please sign in to iCloud in Settings."
        case .restricted:
            return "iCloud account is restricted"
        case .temporarilyUnavailable:
            return "iCloud is temporarily unavailable"
        case .couldNotDetermine:
            return "Could not determine iCloud status"
        @unknown default:
            return "Unknown iCloud status"
        }
    }
    
    func requestiCloudSignIn(completion: @escaping (Bool, String) -> Void) {
        checkAccountStatus()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                completion(false, "Service unavailable")
                return
            }
            
            switch self.accountStatus {
            case .available:
                completion(true, "Successfully signed in to iCloud")
            case .noAccount:
                completion(false, "Please sign in to iCloud in the Settings app")
            case .restricted:
                completion(false, "iCloud account is restricted")
            case .temporarilyUnavailable:
                completion(false, "iCloud is temporarily unavailable. Please try again.")
            case .couldNotDetermine:
                completion(false, "Could not determine iCloud account status")
            @unknown default:
                completion(false, "Unknown iCloud account status")
            }
        }
    }
    
    // MARK: - Permissions
    
    func requestCloudKitPermissions(completion: @escaping (Bool) -> Void) {
        // Modern CloudKit doesn't require explicit permission requests
        // Permission is handled automatically when accessing CloudKit
        DispatchQueue.main.async {
            completion(true)
        }
    }
}

// MARK: - Error Types

enum CloudKitAuthError: Error, LocalizedError {
    case accountNotAvailable
    case permissionDenied
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .accountNotAvailable:
            return "iCloud account is not available"
        case .permissionDenied:
            return "CloudKit permission denied"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}
