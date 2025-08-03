import SwiftUI
import Supabase
import GoogleSignIn

@main
struct MacroApp: App {
    @StateObject private var authManager = AuthManager()

    init() {
        // Configure Google Sign-In
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["GIDClientID"] as? String else {
            fatalError("Could not find GIDClientID in Info.plist")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    Task {
                        do {
                            try await SupabaseManager.shared.client.auth.session(from: url)
                        } catch {
                            print("Error handling deep link: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}

