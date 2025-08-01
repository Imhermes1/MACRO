import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image(systemName: "figure.run")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                Text("CoreTrack")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}

#if DEBUG
#Preview {
    LaunchScreen()
}
#endif
