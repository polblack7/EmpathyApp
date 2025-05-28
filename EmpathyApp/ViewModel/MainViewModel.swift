import Foundation
import SwiftUI
import UIKit



class MainViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var joinChatID: String = ""
    @Published var errorMessage: String = ""
    @Published var activeChat: Chat?
    @Published var currentLobby: Lobby?
    @Published var error: Error?
    @Published var isLoading = false
    @Published var lobbyCode = ""
    @Published var shouldNavigateToChat = false
    
    private let networkService = NetworkService.shared
    
    init() {
        // Load initial data when the view model is created
        Task {
            await loadProfile()
        }
    }
    
    // MARK: - Chat Creation
    func createLobby() async {
        isLoading = true
        error = nil
        
        do {
            currentLobby = try await networkService.createLobby()
            // Create a new chat for the lobby using the lobby ID
            if let lobby = currentLobby {
                let chat = Chat(
                    id: UUID(uuidString: lobby.id) ?? UUID(),
                    createdAt: lobby.createdAt,
                    participants: lobby.participants.compactMap { UUID(uuidString: $0) },
                    lobbyId: lobby.id
                )
                Chat.allChats.append(chat)
                activeChat = chat
                shouldNavigateToChat = true
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Chat Joining
    func joinLobby() async {
        guard !lobbyCode.isEmpty else { return }
        
        isLoading = true
        error = nil
        
        do {
            currentLobby = try await networkService.joinLobby(code: lobbyCode)
            // Create a new chat for the lobby using the lobby ID
            if let lobby = currentLobby {
                let chat = Chat(
                    id: UUID(uuidString: lobby.id) ?? UUID(),
                    createdAt: lobby.createdAt,
                    participants: lobby.participants.compactMap { UUID(uuidString: $0) },
                    lobbyId: lobby.id
                )
                Chat.allChats.append(chat)
                activeChat = chat
                shouldNavigateToChat = true
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Message Loading
    @MainActor
    func loadProfile() async {
        do {
            let user = try await NetworkService.shared.getProfile()
            // Update userManager here if needed, or ensure MainView observes userManager
            UserManager.shared.updateUser(user) // Assuming UserManager is observed by MainView
            // You might want to update some viewModel properties based on the loaded user if necessary
            
            // Load local counters from storage
            let localChatsCount = CountersStorageService.shared.getChatsCount()
            let localSentCardsCount = CountersStorageService.shared.getSentCardsCount()
            print("Local counters loaded in ProfileViewModel loadProfile. Chats: \(localChatsCount), Cards: \(localSentCardsCount)")
            
        } catch {
            // Handle error, maybe set an errorMessage published property
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load profile: \(error.localizedDescription)"
            }
        }
    }
}
