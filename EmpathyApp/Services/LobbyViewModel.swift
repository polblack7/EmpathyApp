import Foundation
import SwiftUI

@MainActor
class LobbyViewModel: ObservableObject {
    @Published var currentLobby: Lobby?
    @Published var error: Error?
    @Published var isLoading = false
    @Published var lobbyCode = ""
    
    private let networkService = NetworkService.shared
    
    func createLobby() async {
        isLoading = true
        error = nil
        
        do {
            currentLobby = try await networkService.createLobby()
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
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func clearError() {
        error = nil
    }
} 