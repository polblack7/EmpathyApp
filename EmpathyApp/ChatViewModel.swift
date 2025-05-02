import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    // MARK: - Properties
    let chat: Chat
    @Published var messages: [Message] = []
    @Published var categories: [String: [Card]]
    @Published var selectedCategory: String
    
    // MARK: - Initialization
    init(chat: Chat) {
        self.chat = chat
        
        // Initialize default categories and cards
        var initialCategories: [String: [Card]] = [
            "Эмоции": [
                Card(title: "Радость", description: "Я чувствую радость и счастье", category: "Эмоции", creatorId: UUID()),
                Card(title: "Грусть", description: "Мне грустно и одиноко", category: "Эмоции", creatorId: UUID()),
                Card(title: "Гнев", description: "Я злюсь и раздражен", category: "Эмоции", creatorId: UUID())
            ],
            "Поддержка": [
                Card(title: "Я с тобой", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam sagittis eleifend mauris, vitae faucibus ipsum. Aenean pharetra ipsum et elementum ornare. Aliquam tincidunt arcu tempus, aliquam enim sed, aliquam est. Ut mollis eleifend ante non elementum. Morbi quis sem finibus, iaculis dolor eget, rutrum risus. Nam vehicula nisl mauris, a ultricies risus tincidunt non. Nunc nisi enim, convallis in iaculis in, consequat eget sapien. Sed ex urna, sagittis a est ut, faucibus eleifend elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Proin vehicula tellus in velit aliquet, quis tristique neque ultricies. Integer vehicula, est et malesuada rutrum, massa magna ultrices lectus, non molestie dui ante at mi. Donec rhoncus dolor non lorem interdum, ut pulvinar diam laoreet.", category: "Поддержка", creatorId: UUID()),
                Card(title: "Я понимаю", description: "Я понимаю твои чувства", category: "Поддержка", creatorId: UUID()),
                Card(title: "Ты сильный", description: "Ты справишься с этим", category: "Поддержка", creatorId: UUID())
            ],
            "Вопросы": [
                Card(title: "Как ты себя чувствуешь?", description: "Расскажи о своих чувствах", category: "Вопросы", creatorId: UUID()),
                Card(title: "Что тебя беспокоит?", description: "Что вызывает у тебя тревогу?", category: "Вопросы", creatorId: UUID()),
                Card(title: "Чем я могу помочь?", description: "Как я могу тебя поддержать?", category: "Вопросы", creatorId: UUID())
            ]
        ]
        
        // Add user's custom categories if they exist
        if let userCategories = User.currentUser?.categories {
            for category in userCategories {
                if initialCategories[category] == nil {
                    initialCategories[category] = []
                }
            }
        }
        
        self.categories = initialCategories
        self.selectedCategory = initialCategories.keys.first ?? ""
    }
    
    // MARK: - Message Management
    func sendCard(_ card: Card) {
        guard let currentUser = User.currentUser else { return }
        
        let message = Message(
            text: "",
            senderId: currentUser.id,
            card: card
        )
        
        messages.append(message)
        
        // Update user's message count
        var updatedUser = currentUser
        updatedUser.messagesCount += 1
        
        // Update current user
        User.currentUser = updatedUser
        
        // Update in all users list
        if let index = User.allUsers.firstIndex(where: { $0.id == currentUser.id }) {
            User.allUsers[index] = updatedUser
        }
    }
    
    // MARK: - Custom Card Management
    func addCustomCard(title: String, description: String, image: UIImage? = nil, category: String) {
        guard !title.isEmpty && !description.isEmpty else { return }
        guard let currentUser = User.currentUser else { return }
        
        let card = Card(
            title: title,
            description: description,
            image: image,
            category: category,
            creatorId: currentUser.id
        )
        
        // Add to existing category or create new one
        if categories[category] != nil {
            categories[category]?.append(card)
        } else {
            categories[category] = [card]
        }
        
        // Update user's cards count
        var updatedUser = currentUser
        updatedUser.cardsCount += 1
        
        // Add category to user's categories if it's new
        if !updatedUser.categories.contains(category) {
            updatedUser.categories.append(category)
        }
        
        // Update current user
        User.currentUser = updatedUser
        
        // Update in all users list
        if let index = User.allUsers.firstIndex(where: { $0.id == currentUser.id }) {
            User.allUsers[index] = updatedUser
        }
    }
    
    // MARK: - Chat Management
    func leaveChat() {
        // Remove chat from all chats
        Chat.allChats.removeAll { $0.id == chat.id }
        
        // Clear messages
        messages.removeAll()
        
        // Reset selected category
        selectedCategory = categories.keys.first ?? ""
    }
} 
