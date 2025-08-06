// SupabaseManager.swift
import Foundation
import Supabase

public class SupabaseManager {
    public static let shared = SupabaseManager()
    public let client: SupabaseClient
    
    private init() {
        guard let supabaseURLString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let supabaseURL = URL(string: supabaseURLString),
              let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String else {
            fatalError("Supabase credentials not found in Info.plist")
        }
        
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}
