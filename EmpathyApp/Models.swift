import Foundation
import SwiftUI

// MARK: - User Model
struct User: Identifiable, Equatable, Codable {
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
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, email, username
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decode(String.self, forKey: .username)
        // Initialize optional fields with default values
        categories = []
        chatsCount = 0
        cardsCount = 0
        messagesCount = 0
        avatarImage = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(username, forKey: .username)
    }
}

// MARK: - User Manager
class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User? {
        didSet {
            User.currentUser = currentUser
        }
    }
    
    private init() {
        self.currentUser = User.currentUser
    }
    
    func updateUser(_ user: User) {
        DispatchQueue.main.async {
            self.currentUser = user
        }
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

// MARK: - Lobby Model
struct Lobby: Identifiable, Codable {
    let id: String
    let createdAt: Date
    let participants: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case participants
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        // Decode ISO8601 date string to Date
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string does not match format")
        }
        
        participants = try container.decode([String].self, forKey: .participants)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        
        // Encode Date to ISO8601 string
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = formatter.string(from: createdAt)
        try container.encode(dateString, forKey: .createdAt)
        
        try container.encode(participants, forKey: .participants)
    }
}

struct UpdateUserRequest: Codable {
    let username: String
    let newPassword: String?
    
    init(username: String, newPassword: String? = nil) {
        self.username = username
        self.newPassword = newPassword
    }
} 
