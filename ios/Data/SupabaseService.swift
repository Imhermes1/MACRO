import Foundation
import Supabase

/**
 * SupabaseService handles database operations using Supabase
 * Replaces FirebaseService with PostgreSQL backend
 * 
 * Documentation: https://supabase.com/docs/reference/swift
 */
class SupabaseService {
    
    // TODO: Replace with your actual Supabase project URL and anon key
    // Configure these in your app's configuration or Info.plist
    private let supabaseURL = "YOUR_SUPABASE_PROJECT_URL" // e.g., "https://your-project.supabase.co"
    private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
    
    private lazy var supabase: SupabaseClient = {
        SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }()
    
    /**
     * Save a group to Supabase PostgreSQL database
     * Replaces Firestore collection with PostgreSQL table
     */
    func saveGroup(_ group: Group) async throws {
        let data: [String: Any] = [
            "id": group.id,
            "name": group.name,
            "members": group.members
        ]
        
        try await supabase.database
            .from("groups")
            .insert(data)
            .execute()
    }
    
    /**
     * Get all groups from Supabase PostgreSQL database
     * Replaces Firestore collection query with PostgreSQL SELECT
     */
    func getGroups() async throws -> [Group] {
        let response = try await supabase.database
            .from("groups")
            .select()
            .execute()
            
        // Parse the response and convert to Group objects
        // TODO: Adjust parsing based on your actual Group model structure
        let groups = try JSONDecoder().decode([Group].self, from: response.data)
        return groups
    }
    
    /**
     * Get groups with callback for backwards compatibility
     * Maintains same API as FirebaseService
     */
    func getGroups(completion: @escaping ([Group]) -> Void) {
        Task {
            do {
                let groups = try await getGroups()
                await MainActor.run {
                    completion(groups)
                }
            } catch {
                await MainActor.run {
                    completion([])
                }
            }
        }
    }
}

// MARK: - Authentication Extensions
extension SupabaseService {
    
    /**
     * Sign in with email and password
     * Documentation: https://supabase.com/docs/guides/auth/auth-email
     */
    func signInWithEmail(email: String, password: String) async throws {
        try await supabase.auth.signIn(email: email, password: password)
    }
    
    /**
     * Sign up with email and password
     */
    func signUpWithEmail(email: String, password: String) async throws {
        try await supabase.auth.signUp(email: email, password: password)
    }
    
    /**
     * Sign in with Google OAuth
     * Documentation: https://supabase.com/docs/guides/auth/social-login/auth-google
     * TODO: Configure Google OAuth provider in Supabase dashboard
     */
    func signInWithGoogle() async throws {
        // Placeholder for Google OAuth implementation
        // Requires additional setup in Supabase dashboard and OAuth configuration
        throw NSError(
            domain: "SupabaseService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Google OAuth setup required - see Supabase docs: https://supabase.com/docs/guides/auth/social-login/auth-google"]
        )
    }
    
    /**
     * Sign in with Apple ID (for iCloud account support)
     * Documentation: https://supabase.com/docs/guides/auth/social-login/auth-apple
     * TODO: Configure Apple OAuth provider in Supabase dashboard
     */
    func signInWithApple() async throws {
        // Placeholder for Apple OAuth implementation
        // Requires additional setup in Supabase dashboard and OAuth configuration
        throw NSError(
            domain: "SupabaseService",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Apple OAuth setup required - see Supabase docs: https://supabase.com/docs/guides/auth/social-login/auth-apple"]
        )
    }
    
    /**
     * Get current user session
     */
    func getCurrentUser() async -> User? {
        return supabase.auth.currentUser
    }
    
    /**
     * Sign out current user
     */
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    /**
     * Check if user is authenticated
     */
    func isAuthenticated() async -> Bool {
        return supabase.auth.currentUser != nil
    }
}

/**
 * Data model for Group (placeholder - adjust based on your actual Group model)
 * TODO: Ensure this matches your existing Group data structure
 */
struct Group: Codable {
    let id: String
    let name: String
    let members: [String]
}