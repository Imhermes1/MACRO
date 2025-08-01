import SwiftUI

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationPhase = 0
    let dotCount: Int
    let animationSpeed: Double
    
    init(dotCount: Int = 3, animationSpeed: Double = 0.6) {
        self.dotCount = dotCount
        self.animationSpeed = animationSpeed
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationPhase == index ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: animationSpeed)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationPhase
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
        .onAppear {
            withAnimation {
                animationPhase = dotCount - 1
            }
        }
    }
}

// MARK: - Typing Indicator with Chat Bubble Style
struct ChatTypingIndicator: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                TypingIndicator()
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Preview
#if DEBUG
struct TypingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Basic Typing Indicator")
                    .foregroundColor(.white)
                    .font(.headline)
                
                TypingIndicator()
                
                Text("Chat Style Typing Indicator")
                    .foregroundColor(.white)
                    .font(.headline)
                
                ChatTypingIndicator()
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
#endif