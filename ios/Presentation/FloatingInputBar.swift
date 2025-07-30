import SwiftUI

struct FloatingInputBar: View {
    @State private var isRecording = false
    @State private var recognizedWords = 0
    @State private var animateRainbow = false

    var body: some View {
        ZStack {
            // Rainbow glow effect
            if isRecording {
                Capsule()
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]),
                            center: .center
                        ),
                        lineWidth: CGFloat(8 + recognizedWords * 2)
                    )
                    .scaleEffect(animateRainbow ? 1.1 : 1.0)
                    .opacity(0.8)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateRainbow)
            }
            HStack {
                Button(action: { /* Plus action */ }) {
                    Image(systemName: "plus")
                }
                TextField("Enter calories...", text: .constant(""))
                    .padding(.horizontal)
                Button(action: {
                    isRecording.toggle()
                    if isRecording {
                        animateRainbow = true
                        recognizedWords = 0 // Reset for demo
                        // Start recording and recognition logic here
                    } else {
                        animateRainbow = false
                        // Stop recording logic here
                    }
                }) {
                    Image(systemName: "mic")
                        .foregroundColor(isRecording ? .accentColor : .primary)
                }
                Button(action: { /* Camera action */ }) {
                    Image(systemName: "camera")
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 8)
            .padding(.horizontal)
        }
    }
}
