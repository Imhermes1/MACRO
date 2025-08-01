import Foundation
import CloudKit
import SwiftUI

/// CloudKit Authentication Service for iCloud account management
/// Following Apple's CloudKit documentation: https://developer.apple.com/documentation/cloudkit
class CloudKitAuthenticationService: ObservableObject {
    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published var isAuthenticated: Bool = false
    @Published var userRecordID: CKRecord.ID?
    @Published var errorMessage: String?
    
    private let container: CKContainer
    private let database: CKDatabase
    
    init() {
        // Use custom container identifier
        self.container = CKContainer(identifier: "iCloud.com.lumoralabs.macro")
        self.database = container.privateCloudDatabase
        
        checkAccountStatus()
        setupNotifications()
    }
    
    // MARK: - Account Status Management
    
    func checkAccountStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.accountStatus = status
                self?.isAuthenticated = (status == .available)
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = nil
                }
                
                // If authenticated, fetch user record ID
                if status == .available {
                    self?.fetchUserRecordID()
                }
            }
        }
    }
    
    private func fetchUserRecordID() {
        container.fetchUserRecordID { [weak self] recordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Failed to fetch user record: \(error.localizedDescription)"
                } else {
                    self?.userRecordID = recordID
                }
            }
        }
    }
    
    // MARK: - iCloud Account Setup
    
    /// Guides user to set up iCloud account
    func promptiCloudSignIn() {
        // Open Settings app for iCloud sign-in
        if let settingsUrl = URL(string: "App-Prefs:APPLE_ID") {
            // Note: This requires iOS 14+ and may require special entitlements
            // For production apps, guide users to Settings > Apple ID manually
            print("Guide user to Settings > [Your Name] > iCloud to sign in")
        }
    }
    
    // MARK: - CloudKit Operations
    
    /// Check if CloudKit is available for operations
    var isCloudKitAvailable: Bool {
        return accountStatus == .available
    }
    
    /// Get user-friendly status message
    var statusMessage: String {
        switch accountStatus {
        case .available:
            return "iCloud is connected and ready"
        case .noAccount:
            return "No iCloud account found. Please sign in to iCloud in Settings."
        case .restricted:
            return "iCloud access is restricted. Check Screen Time or device management settings."
        case .couldNotDetermine:
            return "Checking iCloud status..."
        case .temporarilyUnavailable:
            return "iCloud is temporarily unavailable. Please try again later."
        @unknown default:
            return "Unknown iCloud status"
        }
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .CKAccountChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkAccountStatus()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - CloudKit Account Status Extensions

extension CKAccountStatus {
    var description: String {
        switch self {
        case .available:
            return "Available"
        case .noAccount:
            return "No Account"
        case .restricted:
            return "Restricted"
        case .couldNotDetermine:
            return "Could Not Determine"
        case .temporarilyUnavailable:
            return "Temporarily Unavailable"
        @unknown default:
            return "Unknown"
        }
    }
    
    var systemImage: String {
        switch self {
        case .available:
            return "icloud.fill"
        case .noAccount:
            return "icloud.slash"
        case .restricted:
            return "exclamationmark.icloud"
        case .couldNotDetermine:
            return "questionmark.circle"
        case .temporarilyUnavailable:
            return "icloud.slash.fill"
        @unknown default:
            return "questionmark.circle"
        }
    }
}
