import SwiftUI

enum GlassBackgroundDisplayMode {
    case automatic, prominent, subtle
}

struct GlassEffectModifier<S: Shape>: ViewModifier {
    let isInteractive: Bool
    let shape: S

    func body(content: Content) -> some View {
        content
            .background(shape.fill(.clear))
            .overlay(
                shape.stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

struct GlassBackgroundModifier: ViewModifier {
    let displayMode: GlassBackgroundDisplayMode

    init(displayMode: GlassBackgroundDisplayMode = GlassBackgroundDisplayMode.automatic) {
        self.displayMode = displayMode
    }

    func body(content: Content) -> some View {
        content.background(.clear)
    }
}

struct AdaptiveGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 26.0, *) {
            configuration.label.buttonStyle(.glass)
        } else {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}

struct AdaptiveGlassProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extensions for Glass Effects
extension View {
    func glassEffect<S: Shape>(isInteractive: Bool = false, shape: S = RoundedRectangle(cornerRadius: 20, style: .continuous)) -> some View {
        self.modifier(GlassEffectModifier(isInteractive: isInteractive, shape: shape))
    }

    func glassBackground(displayMode: GlassBackgroundDisplayMode = GlassBackgroundDisplayMode.automatic) -> some View {
        modifier(GlassBackgroundModifier(displayMode: displayMode))
    }

    func adaptiveGlassButton() -> some View {
        buttonStyle(AdaptiveGlassButtonStyle())
    }

    func adaptiveGlassProminentButton() -> some View {
        buttonStyle(AdaptiveGlassProminentButtonStyle())
    }
}

// MARK: - Liquid Glass Constants
struct LiquidGlassConstants {
    static let ultraThinMaterial: Material = .ultraThinMaterial
    static let thinMaterial: Material = .thinMaterial

    static let defaultGlassShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
    static let capsuleGlassShape = Capsule()
    static let roundedRectGlassShape = RoundedRectangle(cornerRadius: 20, style: .continuous)
}

// MARK: - UI Constants
enum UIConstants {
    // MARK: - Layout
    static let tabBarHeight: CGFloat = 80
    static let fabBottomPadding: CGFloat = 90
    static let defaultPadding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24

    // MARK: - Corner Radius
    static let cardCornerRadius: CGFloat = 20
    static let smallCornerRadius: CGFloat = 12
    static let buttonCornerRadius: CGFloat = 25
    static let chatBubbleCornerRadius: CGFloat = 20

    // MARK: - Sizes
    static let fabSize: CGFloat = 64
    static let actionButtonSize: CGFloat = 48
    static let iconSize: CGFloat = 22
    static let smallIconSize: CGFloat = 16

    // MARK: - Chat
    static let chatBubbleMaxWidth: CGFloat = 280 // Fixed width instead of UIScreen dependent
    static let chatPadding: CGFloat = 2
    static let chatSpacing: CGFloat = 8

    // MARK: - Animation
    static let defaultAnimationDuration: Double = 0.3
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let easeOutAnimation = Animation.easeOut(duration: defaultAnimationDuration)

    // MARK: - Opacity
    static let glassMaterialOpacity: Double = 0.15
    static let strokeOpacity: Double = 0.2
    static let disabledOpacity: Double = 0.5
    static let subtleOpacity: Double = 0.7
}

// MARK: - Color Schemes
enum ColorSchemes {
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let fabGradient = LinearGradient(
        gradient: Gradient(colors: [Color.blue, Color.purple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Chat Colors
    static let userBubbleColors = [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]
    static let coachBubbleColor = Color.white.opacity(0.15)
    static let textColor = Color.white

    // MARK: - Status Colors
    static let successColor = Color.green
    static let warningColor = Color.yellow
    static let errorColor = Color.red
    static let infoColor = Color.blue

    // MARK: - Confidence Colors
    static let highConfidenceColor = Color.green
    static let mediumConfidenceColor = Color.yellow
    static let lowConfidenceColor = Color.red
}

// MARK: - Typography
enum Typography {
    static let headlineFont = Font.headline
    static let bodyFont = Font.body
    static let captionFont = Font.caption
    static let caption2Font = Font.caption2
    static let calloutFont = Font.callout
    static let footnoteFont = Font.footnote
    static let subheadlineFont = Font.subheadline

    // MARK: - Custom Fonts
    static let chatFont = Font.body
    static let timestampFont = Font.caption2
    static let buttonFont = Font.system(size: 22, weight: .medium)
}

// MARK: - Spacing
enum Spacing {
    static let tiny: CGFloat = 2
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
    static let xLarge: CGFloat = 16
    static let xxLarge: CGFloat = 20
    static let xxxLarge: CGFloat = 24
    static let huge: CGFloat = 32
}
