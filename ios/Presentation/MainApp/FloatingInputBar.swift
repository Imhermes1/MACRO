import SwiftUI
import Combine


struct FloatingInputBar: View {
    @State private var inputText: String = ""
    @State private var isRecording = false
    @State private var recognizedWords = 0
    @State private var glowRotation: Double = 0
    @State private var glowPulse: Double = 1.0
    @State private var keyboardHeight: CGFloat = 0
    @State private var showAccuracyTip = false
    @State private var dontShowAgain = false
    
    // Access the nutrition chat to send messages
    @State private var nutritionChatView: NutritionChatView?
    
    private var inputBarContent: some View {
        HStack(spacing: 8) {
            Button(action: {
                // Handle additional actions
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            TextField("What did you eat?", text: $inputText)
                .font(.system(.callout, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .textFieldStyle(PlainTextFieldStyle())
                .submitLabel(.send)
                .onSubmit {
                    sendMessage()
                }
            HStack(spacing: 4) {
                Button(action: {
                    isRecording.toggle()
                    if isRecording {
                        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                            glowRotation = 360
                        }
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            glowPulse = 1.15
                        }
                        recognizedWords = 0
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            glowRotation = 0
                            glowPulse = 1.0
                        }
                    }
                }) {
                    ZStack {
                        if isRecording {
                            Circle()
                                .fill(Color.mint.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .scaleEffect(glowPulse)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: glowPulse)
                        }
                        Image(systemName: isRecording ? "stop.fill" : "mic")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isRecording ? .pink : .white)
                            .frame(width: 44, height: 44)
                            .scaleEffect(isRecording ? 1.1 : 1.0)
                    }
                }
                Button(action: {
                    // Handle camera action
                }) {
                    Image(systemName: "camera")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                        .frame(width: 36, height: 36)
                }
            }
            if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .yellow.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .overlay(
            isRecording ?
                AnyView(
                    Capsule()
                        .strokeBorder(
                            AngularGradient(
                                colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                                center: .center,
                                startAngle: .degrees(glowRotation),
                                endAngle: .degrees(glowRotation + 360)
                            ),
                            lineWidth: 3
                        )
                ) : AnyView(EmptyView())
        )
        .shadow(radius: 8)
        .padding(.horizontal, 16)
    }

    init() {
        // Initialize dontShowAgain from UserDefaults
        self._dontShowAgain = State(initialValue: UserDefaults.standard.bool(forKey: "hide_accuracy_tip"))
    }
    
    var body: some View {
        ZStack {
            inputBarContent
            
            // Accuracy tip overlay when keyboard is open
            if showAccuracyTip {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            
                            Text("💡 Pro Tip")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showAccuracyTip = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.caption)
                            }
                        }
                        
                        Text("Be as accurate as possible when logging food! Include brands, weights, and serving sizes. The more detailed you are, the more accurate your nutrition tracking will be.")
                            .font(.system(.callout, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Button(action: {
                                dontShowAgain.toggle()
                                UserDefaults.standard.set(dontShowAgain, forKey: "hide_accuracy_tip")
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                                        .foregroundColor(dontShowAgain ? .cyan : .white.opacity(0.7))
                                        .font(.system(size: 16))
                                    
                                    Text("Don't show again")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120) // Position above input bar
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .bottom)).combined(with: .offset(y: 20)),
                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .bottom)).combined(with: .offset(y: 20))
                    ))
                }
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: inputText.isEmpty)
        .offset(y: -keyboardHeight)
        .onReceive(Publishers.keyboardHeight) { newKeyboardHeight in
            withAnimation(.easeInOut(duration: 0.3)) {
                self.keyboardHeight = newKeyboardHeight
            }
            
            // Show tip when keyboard appears (if not disabled)
            if newKeyboardHeight > 0 && !UserDefaults.standard.bool(forKey: "hide_accuracy_tip") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showAccuracyTip = true
                    }
                }
            } else if newKeyboardHeight == 0 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showAccuracyTip = false
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Send message to nutrition chat
        // Note: This needs to be connected to the actual NutritionChatView instance
        // For now, we'll use NotificationCenter to communicate
        NotificationCenter.default.post(
            name: NSNotification.Name("NutritionInputReceived"),
            object: trimmedText
        )
        
        inputText = ""
    }
}

// MARK: - Keyboard Height Publisher
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                guard let keyboardFrame = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return 0
                }
                return keyboardFrame.cgRectValue.height
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ -> CGFloat in 0 }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

