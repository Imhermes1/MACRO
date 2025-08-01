import Foundation

enum ChatType: String, CaseIterable, Hashable {
    case food
    case coach
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let sender: Sender
    let timestamp: Date
    let features: ChatFeatures?
    
    init(text: String, sender: Sender, timestamp: Date = Date(), features: ChatFeatures? = nil) {
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
        self.features = features
    }
    
    enum Sender {
        case user, coach
    }
}

// MARK: - Chat Features Configuration
struct ChatFeatures {
    let allowEditing: Bool
    let showTimestamp: Bool
    let allowReactions: Bool
    
    init(
        allowEditing: Bool = false,
        showTimestamp: Bool = false,
        allowReactions: Bool = false
    ) {
        self.allowEditing = allowEditing
        self.showTimestamp = showTimestamp
        self.allowReactions = allowReactions
    }
    
    static let foodChat = ChatFeatures(allowEditing: true, showTimestamp: false)
    static let coachChat = ChatFeatures(allowEditing: false, showTimestamp: true)
    static let standard = ChatFeatures()
} 