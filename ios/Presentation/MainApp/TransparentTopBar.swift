import SwiftUI

struct TransparentTopBar: View {
    var showRightButton: Bool = false

    var body: some View {
        HStack {
            // Left navigation button
            Button(action: {
                // Navigation action
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primary)
                    .padding()
            }
            .background(.ultraThinMaterial)
            .clipShape(Circle())

            Spacer()

            // Center title
            Text("Macro by the Moral Labs")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

            Spacer()

            // Right button (invisible if not shown)
            if showRightButton {
                Button(action: {
                    // Placeholder action
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                        .padding()
                }
                .background(.ultraThinMaterial)
                .clipShape(Circle())
            } else {
                // Invisible placeholder for layout
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(radius: 8)
    }
}
