import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var joinChatID: String = ""
    @Published var errorMessage: String = ""
    @Published var activeChat: Chat?
    
    // MARK: - Chat Creation
    func createChat() {
        // Reset error message
        errorMessage = ""
        
        // Create new chat
        let newChat = Chat(
            participants: [User.currentUser?.id ?? UUID()] // Add current user as participant
        )
        
        // Add to all chats
        Chat.allChats.append(newChat)
        
        // Set active chat
        activeChat = newChat
    }
    
    // MARK: - Chat Joining
    func joinChat() {
        // Reset error message
        errorMessage = ""
        
        // Validate input
        guard !joinChatID.isEmpty else {
            errorMessage = "Введите ID чата"
            return
        }
        
        // Find chat by ID
        if let chat = Chat.allChats.first(where: { $0.id.uuidString == joinChatID }) {
            // Add current user to participants if not already there
            if !chat.participants.contains(User.currentUser?.id ?? UUID()) {
                var updatedChat = chat
                updatedChat.participants.append(User.currentUser?.id ?? UUID())
                if let index = Chat.allChats.firstIndex(where: { $0.id == chat.id }) {
                    Chat.allChats[index] = updatedChat
                }
            }
            activeChat = chat
        } else {
            errorMessage = "Чат с ID \(joinChatID) не найден"
        }
    }
} 