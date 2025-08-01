import SwiftUI

struct SmartInputBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    let placeholder: String
    let onSend: () -> Void
    let onMic: () -> Void
    let onCamera: (() -> Void)?
    let showCamera: Bool
    let isMicActive: Bool
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var isExpanded = false

    var body: some View {
        Group {
            if isFocused || isExpanded {
                expandedBar
            } else {
                miniPill
            }
        }
        .padding(.bottom, isFocused ? (keyboardHeight > 0 ? keyboardHeight - 34 : 0) : 0)
        .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: isFocused)
        .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: isExpanded)
        .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: keyboardHeight)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                self.keyboardHeight = frame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            self.keyboardHeight = 0
        }
    }

    private var miniPill: some View {
        HStack(spacing: 12) {
            // Shortened input placeholder
            HStack(spacing: 8) {
                Image(systemName: "text.bubble")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(placeholder)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(shape: RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                    isExpanded = true
                    isFocused = true
                }
            }
            
            // Prominent Camera Button
            if showCamera, let onCamera = onCamera {
                Button(action: onCamera) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 52, height: 52)
                        .glassEffect(
                            isInteractive: true,
                            shape: Circle()
                        )
                }
            }
            
            // Prominent Mic Button
            Button(action: onMic) {
                Image(systemName: isMicActive ? "mic.fill.circle.fill" : "mic.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isMicActive ? .red : .white)
                    .frame(width: 52, height: 52)
                    .glassEffect(
                        isInteractive: true,
                        shape: Circle()
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    private var expandedBar: some View {
        VStack(spacing: 12) {
            // Expanded Text Input
            HStack(spacing: 12) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .focused($isFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassEffect(shape: RoundedRectangle(cornerRadius: 20))
                    .foregroundColor(.white)
                    .submitLabel(.send)
                    .lineLimit(1...5)
                    .onSubmit(sendMessage)
                
                // Send Button
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(text.isEmpty ? .white.opacity(0.5) : .white)
                        .frame(width: 44, height: 44)
                        .glassEffect(
                            isInteractive: !text.isEmpty,
                            shape: Circle()
                        )
                }
                .disabled(text.isEmpty)
            }
            
            // Action Buttons Row
            HStack(spacing: 12) {
                // Camera Button
                if showCamera, let onCamera = onCamera {
                    Button(action: onCamera) {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Camera")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .glassEffect(
                            isInteractive: true,
                            shape: RoundedRectangle(cornerRadius: 16)
                        )
                    }
                }
                
                // Mic Button
                Button(action: onMic) {
                    HStack(spacing: 8) {
                        Image(systemName: isMicActive ? "mic.fill.circle.fill" : "mic.fill")
                            .font(.system(size: 16, weight: .medium))
                        Text(isMicActive ? "Recording" : "Voice")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(isMicActive ? .red : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .glassEffect(
                        isInteractive: true,
                        shape: RoundedRectangle(cornerRadius: 16)
                    )
                }
                
                Spacer()
                
                // Close Button
                Button(action: {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                        isExpanded = false
                        isFocused = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .glassEffect(shape: Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassBackground(displayMode: .automatic)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 20)
    }
    
    private func sendMessage() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSend()
        text = ""
        withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
            isExpanded = false
            isFocused = false
        }
    }
}

struct SmartInputBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                SmartInputBar(
                    text: .constant(""),
                    placeholder: "Ask your coach...",
                    onSend: {}, onMic: {}, onCamera: {},
                    showCamera: true, isMicActive: false
                )
            }
        }
        .preferredColorScheme(.dark)
    }
} 
