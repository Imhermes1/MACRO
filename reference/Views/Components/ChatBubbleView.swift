import SwiftUI

// ChatMessage and ChatFeatures are now imported from Models/ChatMessage.swift

// MARK: - Chat Bubble View
struct ChatBubbleView: View {
    let message: ChatMessage
    let onEdit: ((String) -> Void)?
    let style: ChatBubbleStyle
    let features: ChatFeatures
    
    init(
        message: ChatMessage, 
        onEdit: ((String) -> Void)? = nil,
        style: ChatBubbleStyle = .default,
        features: ChatFeatures? = nil
    ) {
        self.message = message
        self.onEdit = onEdit
        self.style = style
        self.features = features ?? message.features ?? .standard
    }
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
                userBubble
            } else {
                coachBubble
                Spacer()
            }
        }
    }
    
    private var userBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 8) {
                // Edit button
                if features.allowEditing, let onEdit = onEdit {
                    Button(action: {
                        onEdit(message.text)
                    }) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(4)
                            .glassEffect(shape: Circle())
                    }
                }
                
                Text(message.text)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassEffect(
                        isInteractive: true,
                        shape: RoundedRectangle(cornerRadius: 20)
                    )
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
            
            if features.showTimestamp {
                timestampView
            }
        }
    }
    
    private var coachBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.text)
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glassEffect(
                    shape: RoundedRectangle(cornerRadius: 20)
                )
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            
            if features.showTimestamp {
                timestampView
            }
        }
    }
    
    // MARK: - Timestamp
    private var timestampView: some View {
        Text(timeString)
            .font(.caption2)
            .foregroundColor(.white.opacity(0.5))
            .padding(.horizontal, 4)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

// MARK: - Chat Bubble Style
struct ChatBubbleStyle {
    let userBubbleColors: [Color]
    let coachBubbleColor: Color
    
    static let `default` = ChatBubbleStyle(
        userBubbleColors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
        coachBubbleColor: Color.white.opacity(0.15)
    )
    
    static let food = ChatBubbleStyle(
        userBubbleColors: [Color.green.opacity(0.8), Color.blue.opacity(0.8)],
        coachBubbleColor: Color.white.opacity(0.15)
    )
    
    static let coach = ChatBubbleStyle(
        userBubbleColors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
        coachBubbleColor: Color.white.opacity(0.15)
    )
}

// MARK: - Preview
#if DEBUG
struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ChatBubbleView(
                    message: ChatMessage(text: "I had a chicken salad for lunch", sender: .user),
                    features: .foodChat
                )
                
                ChatBubbleView(
                    message: ChatMessage(text: "Great choice! That sounds healthy. Did you have any dressing with it?", sender: .coach),
                    features: .coachChat
                )
                
                ChatBubbleView(
                    message: ChatMessage(text: "Yes, some olive oil and balsamic vinegar", sender: .user),
                    onEdit: { text in print("Edit: \(text)") },
                    style: .food,
                    features: .foodChat
                )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
