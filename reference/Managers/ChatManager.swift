import Foundation
import SwiftUI
import Combine

@MainActor
class ChatManager: ObservableObject {
    @Published var chats: [ChatType: [ChatMessage]] = [
        .food: [],
        .coach: []
    ]
    
    func messages(for type: ChatType) -> [ChatMessage] {
        chats[type] ?? []
    }
    
    func addMessage(_ message: ChatMessage, to type: ChatType) {
        chats[type, default: []].append(message)
    }
    
    func addMessage(text: String, sender: ChatMessage.Sender, to type: ChatType) {
        let message = ChatMessage(text: text, sender: sender)
        addMessage(message, to: type)
    }
    
    func removeMessage(_ message: ChatMessage, from type: ChatType) {
        chats[type]?.removeAll { $0.id == message.id }
    }
    
    func resetChat(for type: ChatType, withGreeting greeting: ChatMessage? = nil) {
        chats[type] = []
        if let greeting = greeting {
            chats[type]?.append(greeting)
        }
    }
} 
