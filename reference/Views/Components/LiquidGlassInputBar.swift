import SwiftUI

// MARK: - Quick Action Model
struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    init(title: String, icon: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
}

// MARK: - Liquid Glass Input Bar
struct LiquidGlassInputBar: View {
    @Binding var text: String
    @State private var isExpanded = false
    @State private var showQuickActions = false
    @State private var textFieldHeight: CGFloat = 40
    @State private var isRecording = false
    @State private var recordingScale: CGFloat = 1.0
    
    // Animation states for liquid effects
    @State private var plusButtonScale: CGFloat = 1.0
    @State private var cameraButtonScale: CGFloat = 1.0
    @State private var micButtonScale: CGFloat = 1.0
    @State private var sendButtonScale: CGFloat = 1.0
    @State private var sendButtonRipple: CGFloat = 0.0
    @State private var textFieldScale: CGFloat = 1.0
    
    let placeholder: String
    let quickActions: [QuickAction]
    let onSend: (String) -> Void
    let onMicTap: () -> Void
    let onCameraTap: () -> Void
    
    init(
        text: Binding<String> = .constant(""),
        placeholder: String = "Message",
        quickActions: [QuickAction] = [],
        onSend: @escaping (String) -> Void = { _ in },
        onMicTap: @escaping () -> Void = {},
        onCameraTap: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.quickActions = quickActions
        self.onSend = onSend
        self.onMicTap = onMicTap
        self.onCameraTap = onCameraTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Quick Actions Menu (when expanded)
            if showQuickActions && !quickActions.isEmpty {
                QuickActionsMenu(
                    actions: quickActions,
                    isVisible: $showQuickActions
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showQuickActions)
            }
            
            // Main Input Bar
            if #available(iOS 26.0, *) {
                GlassEffectContainer {
                    HStack(spacing: 6) {
                        // Quick Actions Button with enhanced liquid effect
                        Button(action: animatedToggleQuickActions) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                                .rotationEffect(.degrees(showQuickActions ? 45 : 0))
                                .scaleEffect(plusButtonScale)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .scaleEffect(showQuickActions ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: showQuickActions)
                        
                        // Text Input Field
                        HStack {
                            TextField(placeholder, text: $text, axis: .vertical)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.primary)
                                .lineLimit(1...5)
                                .onChange(of: text) { _, newValue in
                                    updateTextFieldHeight()
                                }
                                .placeholder(when: text.isEmpty) {
                                    Text(placeholder)
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 17, weight: .regular))
                                }
                                .onTapGesture {
                                    animatedTextFieldTap()
                                }
                            
                            // Send Button with enhanced liquid effect
                            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                ZStack {
                                    // Ripple effect
                                    Circle()
                                        .stroke(Color.accentColor.opacity(0.8), lineWidth: 2)
                                        .scaleEffect(sendButtonRipple)
                                        .opacity(1.0 - sendButtonRipple * 0.7)
                                    
                                    Button(action: animatedSendMessage) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.accentColor)
                                            .scaleEffect(sendButtonScale)
                                    }
                                    .buttonStyle(.glass)
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                }
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: text)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .glassEffect()
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.black.opacity(0.3), lineWidth: 1.5)
                        )
                        .frame(height: max(44, textFieldHeight))
                        .scaleEffect(textFieldScale)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: textFieldScale)
                        
                        // Camera Button with enhanced liquid effect
                        Button(action: animatedCameraTap) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                                .scaleEffect(cameraButtonScale)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        
                        // Microphone Button with enhanced liquid effect
                        Button(action: animatedMicTap) {
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(isRecording ? .red : .primary)
                                .scaleEffect(micButtonScale * recordingScale)
                        }
                        .buttonStyle(.glass)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .animation(.easeInOut(duration: 0.2), value: isRecording)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.clear) // Ensure fully transparent background
                }
                // Removed .backgroundExtensionEffect() to prevent mirroring the input bar
            } else {
                // Fallback on earlier versions
            }
        }
        .padding(.bottom, 0)
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showQuickActions)
    }
    
    // MARK: - Enhanced Animation Methods
    private func animatedToggleQuickActions() {
        // Trigger liquid animation
        withAnimation(.easeOut(duration: 0.1)) {
            plusButtonScale = 0.85
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            plusButtonScale = 1.0
        }
        
        // Original functionality
        toggleQuickActions()
    }
    
    private func animatedSendMessage() {
        // Trigger liquid animation
        withAnimation(.easeOut(duration: 0.1)) {
            sendButtonScale = 0.8
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            sendButtonScale = 1.0
        }
        
        // Ripple effect
        withAnimation(.easeOut(duration: 0.6)) {
            sendButtonRipple = 1.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            sendButtonRipple = 0.0
        }
        
        // Original functionality
        sendMessage()
    }
    
    private func animatedCameraTap() {
        // Trigger liquid animation
        withAnimation(.easeOut(duration: 0.1)) {
            cameraButtonScale = 0.85
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            cameraButtonScale = 1.0
        }
        
        // Original functionality
        onCameraTap()
    }
    
    private func animatedMicTap() {
        // Trigger liquid animation
        withAnimation(.easeOut(duration: 0.1)) {
            micButtonScale = 0.85
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            micButtonScale = 1.0
        }
        
        // Original functionality
        handleMicTap()
    }
    
    private func animatedTextFieldTap() {
        // Trigger liquid animation
        withAnimation(.easeOut(duration: 0.1)) {
            textFieldScale = 0.95
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            textFieldScale = 1.0
        }
    }
    
    // MARK: - Private Methods
    private func toggleQuickActions() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showQuickActions.toggle()
        }
    }
    
    private func sendMessage() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        onSend(trimmedText)
        text = ""
        updateTextFieldHeight()
        
        // Close quick actions if open
        if showQuickActions {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showQuickActions = false
            }
        }
    }
    
    private func handleMicTap() {
        if isRecording {
            // Stop recording
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isRecording = false
                recordingScale = 1.0
            }
        } else {
            // Start recording
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isRecording = true
                recordingScale = 1.2
            }
            
            // Pulse animation for recording
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                recordingScale = 1.0
            }
        }
        
        onMicTap()
    }
    
    private func updateTextFieldHeight() {
        // Calculate height based on text content
        let lines = text.components(separatedBy: .newlines).count
        let baseHeight: CGFloat = 44
        let lineHeight: CGFloat = 22
        textFieldHeight = min(baseHeight + CGFloat(max(0, lines - 1)) * lineHeight, 130)
    }
}

// MARK: - Quick Actions Menu
struct QuickActionsMenu: View {
    let actions: [QuickAction]
    @Binding var isVisible: Bool
    
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                VStack(spacing: 8) {
                    ForEach(actions) { action in
                        QuickActionButton(action: action) {
                            action.action()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isVisible = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .glassEffect()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        } else {
            // Fallback on earlier versions
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let action: QuickAction
    let onTap: () -> Void
    
    var body: some View {
        if #available(iOS 26.0, *) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: action.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(action.color)
                        .frame(width: 24, height: 24)
                    
                    Text(action.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.glass)
        } else {
            // Fallback on earlier versions
        };if #available(iOS 26.0, *) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: action.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(action.color)
                        .frame(width: 24, height: 24)
                    
                    Text(action.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.glass)
        } else {
            // Fallback on earlier versions
        }
    }
}

// MARK: - Placeholder Modifier for TextField
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
#if DEBUG
struct LiquidGlassInputBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background gradient to test transparency
            LinearGradient(
                colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                LiquidGlassInputBar(
                    text: .constant(""),
                    placeholder: "Type a message...",
                    quickActions: [
                        QuickAction(title: "Photo", icon: "photo", color: .blue) {
                            print("Photo tapped")
                        },
                        QuickAction(title: "Document", icon: "doc", color: .green) {
                            print("Document tapped")
                        },
                        QuickAction(title: "Location", icon: "location", color: .orange) {
                            print("Location tapped")
                        }
                    ],
                    onSend: { message in
                        print("Message sent: \(message)")
                    },
                    onMicTap: {
                        print("Mic tapped")
                    },
                    onCameraTap: {
                        print("Camera tapped")
                    }
                )
                .padding(.bottom, 34) // Safe area
            }
        }
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 15 Pro")
    }
}
#endif
