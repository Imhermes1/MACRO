
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var session = SessionStore()

    var body: some View {
        ZStack {
            UniversalBackground()
            
            if session.isLoggedIn {
                if !session.isProfileComplete {
                    ProfileSetupView(session: session)
                } else if !session.isBMIComplete {
                    BMICalculatorView(session: session)
                } else {
                    MainAppView()
                }
            } else {
                LoginView(session: session)
            }
        }
        .ignoresSafeArea(.all) // Ensure full screen coverage
        .onAppear {
            session.listen()
        }
    }
}
