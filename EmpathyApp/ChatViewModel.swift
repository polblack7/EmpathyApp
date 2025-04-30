import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    // MARK: - Properties
    let chat: Chat
    @Published var messages: [Message] = []
    @Published var categories: [String: [String]]
    @Published var selectedCategory: String
    
    // MARK: - Initialization
    init(chat: Chat) {
        self.chat = chat
        
        // Initialize default categories and cards
        var initialCategories: [String: [String]] = [
            "Эмоции": [
                "Я рад",
                "Мне грустно",
                "Я разочарован",
                "Я счастлив",
                "Я волнуюсь"
            ],
            "Поддержка": [
                "Я с тобой",
                "Ты не один",
                "Я тебя понимаю",
                "Я здесь для тебя",
                "Ты справишься"
            ],
            "Вопросы": [
                "Как ты себя чувствуешь?",
                "Что тебя беспокоит?",
                "Чем я могу помочь?",
                "Что тебе нужно?",
                "Как ты хочешь это обсудить?"
            ],
            "Действия": [
                "Давай поговорим",
                "Можно обнять?",
                "Хочешь помолчать?",
                "Давай подумаем вместе",
                "Можно я помогу?"
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
    func sendCard(text: String) {
        guard let currentUser = User.currentUser else { return }
        
        let message = Message(
            text: text,
            senderId: currentUser.id
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
    func addCustomCard(category: String, text: String) {
        guard !text.isEmpty else { return }
        
        // Add to existing category or create new one
        if categories[category] != nil {
            categories[category]?.append(text)
        } else {
            categories[category] = [text]
        }
        
        // Update user's cards count
        if let currentUser = User.currentUser {
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