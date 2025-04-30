import Foundation

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    var username: String
    var password: String
    var chatsCount: Int
    var cardsCount: Int
    var messagesCount: Int
    var categories: [String]
    
    // Static properties for user management
    static var allUsers: [User] = []
    static var currentUser: User?
    
    // Default categories
    static let defaultCategories = [
        "Радость",
        "Грусть",
        "Гнев",
        "Страх",
        "Удивление",
        "Отвращение"
    ]
    
    init(id: UUID = UUID(), 
         email: String, 
         username: String, 
         password: String, 
         chatsCount: Int = 0, 
         cardsCount: Int = 0, 
         messagesCount: Int = 0, 
         categories: [String] = User.defaultCategories) {
        self.id = id
        self.email = email
        self.username = username
        self.password = password
        self.chatsCount = chatsCount
        self.cardsCount = cardsCount
        self.messagesCount = messagesCount
        self.categories = categories
    }
}

// MARK: - Chat Model
struct Chat: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    var participants: [UUID] // User IDs
    var messages: [Message]
    
    // Static property for all chats
    static var allChats: [Chat] = []
    
    init(id: UUID = UUID(), 
         createdAt: Date = Date(), 
         participants: [UUID], 
         messages: [Message] = []) {
        self.id = id
        self.createdAt = createdAt
        self.participants = participants
        self.messages = messages
    }
}

// MARK: - Message Model
struct Message: Identifiable, Codable {
    let id: UUID
    let text: String
    let senderId: UUID
    let timestamp: Date
    
    init(id: UUID = UUID(), 
         text: String, 
         senderId: UUID, 
         timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.timestamp = timestamp
    }
} 