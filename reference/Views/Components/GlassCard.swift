import SwiftUI

// MARK: - Glass Card Modifier
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .glassEffect(shape: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Glass Card with Custom Padding
struct GlassCardCustom<Content: View>: View {
    let content: Content
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    
    init(
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .glassEffect(shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Interactive Glass Card
struct InteractiveGlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .glassEffect(isInteractive: true, shape: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Glass Container with Background
struct GlassContainer<Content: View>: View {
    let content: Content
    let displayMode: GlassBackgroundDisplayMode
    
    init(displayMode: GlassBackgroundDisplayMode = .automatic, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.displayMode = displayMode
    }
    
    var body: some View {
        content
            .glassBackground(displayMode: displayMode)
    }
}

// MARK: - Glass Effect Container for Multiple Shapes
struct GlassEffectContainerView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                content
            }
        } else {
            // Fallback on earlier iOS versions
            content
                .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Preview
#if DEBUG
struct GlassCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                GlassCard {
                    VStack {
                        Text("Standard Glass Card")
                            .foregroundColor(.white)
                        Text("With iOS 26 Liquid Glass")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                GlassCardCustom(
                    padding: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
                    cornerRadius: 12
                ) {
                    Text("Custom Glass Card")
                        .foregroundColor(.white)
                }
                
                InteractiveGlassCard {
                    VStack {
                        Text("Interactive Glass Card")
                            .foregroundColor(.white)
                        Text("With interactive effects")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                GlassContainer {
                    VStack {
                        Text("Glass Container")
                            .foregroundColor(.white)
                        Text("With background effect")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                }
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 15 Pro")
    }
}
#endif

