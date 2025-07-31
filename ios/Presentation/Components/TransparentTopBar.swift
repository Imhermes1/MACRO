import SwiftUI

/// A reusable, transparent navigation bar that can be placed on top of any view.
///
/// This component provides a consistent look and feel for navigation across the app. It includes optional left and right buttons, and a customizable title.
///
/// ### Usage
///
/// ```
/// TransparentTopBar(
///     showRightButton: true,
///     leftAction: {
///         // Handle back navigation
///     },
///     rightAction: {
///         // Navigate to settings
///     },
///     title: "My Screen"
/// )
/// ```
public struct TransparentTopBar: View {
    /// Determines whether the right-hand navigation button is visible.
    public var showRightButton: Bool
    /// The action to perform when the left-hand navigation button is tapped.
    public var leftAction: (() -> Void)?
    /// The action to perform when the right-hand navigation button is tapped.
    public var rightAction: (() -> Void)?
    /// The title displayed in the center of the navigation bar.
    public var title: String
    /// The SF Symbol name for the left-hand navigation button icon.
    public var leftIcon: String
    /// The SF Symbol name for the right-hand navigation button icon.
    public var rightIcon: String

    /// Creates a new transparent navigation bar.
    /// - Parameters:
    ///   - showRightButton: A boolean indicating if the right button should be shown. Defaults to `false`.
    ///   - leftAction: The closure to execute when the left button is tapped. Defaults to `nil`.
    ///   - rightAction: The closure to execute when the right button is tapped. Defaults to `nil`.
    ///   - title: The title to display. If `nil`, the default title `"Macro"` is used.
    ///   - leftIcon: The SF Symbol for the left button. Defaults to `"chevron.left"`.
    ///   - rightIcon: The SF Symbol for the right button. Defaults to `"person.circle"`.
    public init(
        showRightButton: Bool = false,
        leftAction: (() -> Void)? = nil,
        rightAction: (() -> Void)? = nil,
        title: String? = nil, // Allow nil to use the default
        leftIcon: String = "chevron.left",
        rightIcon: String = "person.circle"
    ) {
        self.showRightButton = showRightButton
        self.leftAction = leftAction
        self.rightAction = rightAction
        // If a title is passed in, use it. Otherwise, use the property's default.
        self.title = title ?? "Macro"
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
    }

    public var body: some View {
        HStack {
            // Left navigation button
            Button(action: {
                leftAction?()
            }) {
                Image(systemName: leftIcon)
                    .foregroundColor(.primary)
                    .padding()
            }
            .background(.ultraThinMaterial)
            .clipShape(Circle())

            Spacer()

            // Center title
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

            Spacer()

            // Right button (settings/profile when shown)
            if showRightButton {
                Button(action: {
                    rightAction?()
                }) {
                    Image(systemName: rightIcon)
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

#Preview {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.green]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack {
            TransparentTopBar(showRightButton: true)
                .padding()
            Spacer()
        }
    }
}
