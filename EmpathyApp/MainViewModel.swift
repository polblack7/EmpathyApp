import Foundation
import SwiftUI

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
}
