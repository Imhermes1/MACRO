import Foundation
import Combine

@MainActor
class UserManager: ObservableObject {
    enum UserTier: String, Codable {
        case free, basic, pro
    }
    @Published var userTier: UserTier = .free
    
    func upgrade(to tier: UserTier) {
        userTier = tier
    }
} 