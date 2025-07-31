import Foundation

/// Represents the different cloud storage options available for user profiles
enum CloudProvider: String, CaseIterable, Hashable {
    case localOnly = "local"
    case cloudKit = "cloudkit"
    case firebase = "firebase"
    
    var displayName: String {
        switch self {
        case .localOnly:
            return "Local Only"
        case .cloudKit:
            return "iCloud (Recommended)"
        case .firebase:
            return "Firebase"
        }
    }
    
    var description: String {
        switch self {
        case .localOnly:
            return "Keeps data on this device only"
        case .cloudKit:
            return "Syncs across your Apple devices"
        case .firebase:
            return "Cross-platform cloud storage"
        }
    }
    
    /// Indicates if this provider requires internet connectivity
    var requiresInternet: Bool {
        switch self {
        case .localOnly:
            return false
        case .cloudKit, .firebase:
            return true
        }
    }
    
    /// Indicates if this provider is available on the current platform
    var isAvailableOnCurrentPlatform: Bool {
        switch self {
        case .localOnly, .firebase:
            return true
        case .cloudKit:
            // CloudKit is only available on Apple platforms
            #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
            return true
            #else
            return false
            #endif
        }
    }
}
