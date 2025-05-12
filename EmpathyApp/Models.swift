import Foundation
import SwiftUI

// MARK: - User Model
struct User: Identifiable, Equatable {
    let id: UUID
    let email: String
    var username: String
    var avatarImage: UIImage?
    var categories: [String]
    var chatsCount: Int
    var cardsCount: Int
    var messagesCount: Int
    
    static var currentUser: User?
    static var allUsers: [User] = []
    
    init(id: UUID = UUID(), email: String, username: String, avatarImage: UIImage? = nil, categories: [String] = [], chatsCount: Int = 0, cardsCount: Int = 0, messagesCount: Int = 0) {
        self.id = id
        self.email = email
        self.username = username
        self.avatarImage = avatarImage
        self.categories = categories
        self.chatsCount = chatsCount
        self.cardsCount = cardsCount
        self.messagesCount = messagesCount
    }
}

// MARK: - Chat Model
struct Chat: Identifiable {
    let id: UUID
    let createdAt: Date
    var participants: [UUID]
    
    static var allChats: [Chat] = []
    
    init(id: UUID = UUID(), createdAt: Date = Date(), participants: [UUID]) {
        self.id = id
        self.createdAt = createdAt
        self.participants = participants
    }
}

// MARK: - Message Model
struct Message: Identifiable {
    let id: UUID
    let text: String
    let senderId: UUID
    let timestamp: Date
    let card: Card?
    
    init(id: UUID = UUID(), text: String, senderId: UUID, timestamp: Date = Date(), card: Card? = nil) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.timestamp = timestamp
        self.card = card
    }
}

// MARK: - Card Model
struct Card: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let image: UIImage?
    let category: String
    let creatorId: UUID
    let createdAt: Date
    
    init(id: UUID = UUID(), title: String, description: String, image: UIImage? = nil, category: String, creatorId: UUID, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.category = category
        self.creatorId = creatorId
        self.createdAt = createdAt
    }
} 