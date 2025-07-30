import SwiftUI

struct SettingsMenu: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.headline)
            Text("Notifications")
                .font(.headline)
            Text("Privacy")
                .font(.headline)
            Text("About")
                .font(.headline)
        }
    }
}
