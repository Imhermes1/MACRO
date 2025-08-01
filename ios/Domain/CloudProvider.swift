import Foundation

/// Represents the different cloud storage options available for user profiles
enum CloudProvider: String, CaseIterable, Hashable {
    case localOnly = "local"
    case cloudKit = "cloudkit"
    case supabase = "supabase"
    
    var displayName: String {
        switch self {
        case .localOnly:
            return "Local Only"
        case .cloudKit:
            return "iCloud (Recommended)"
        case .supabase:
            return "Supabase"
        }
    }
    
    var description: String {
        switch self {
        case .localOnly:
            return "Keeps data on this device only"
        case .cloudKit:
            return "Syncs across your Apple devices"
        case .supabase:
            return "Cross-platform cloud storage"
        }
    }
    
    /// Indicates if this provider requires internet connectivity
    var requiresInternet: Bool {
        switch self {
        case .localOnly:
            return false
        case .cloudKit, .supabase:
            return true
        }
    }
    
    /// Indicates if this provider is available on the current platform
    var isAvailableOnCurrentPlatform: Bool {
        switch self {
        case .localOnly, .supabase:
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
