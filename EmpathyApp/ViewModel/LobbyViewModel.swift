import Foundation
import SwiftUI

@MainActor
class LobbyViewModel: ObservableObject {
    @Published var currentLobby: Lobby?
    @Published var error: Error?
    @Published var isLoading = false
    @Published var lobbyCode = ""
    @Published var shouldNavigateToChat = false
    @Published var activeChat: Chat?
    
    private let networkService = NetworkService.shared
    
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
    
    func clearError() {
        error = nil
    }
} 