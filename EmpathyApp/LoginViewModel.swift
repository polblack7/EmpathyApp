import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    
    // MARK: - Validation Methods
    private func validateInput() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    // MARK: - Login Method
    func login() async {
        // Reset error message
        errorMessage = ""
        isLoading = true
        
        do {
            let response = try await NetworkService.shared.login(email: email, password: password)
            
            // Create user from response
            let user = User(
                id: UUID(uuidString: response.user.id) ?? UUID(),
                email: response.user.email,
                username: response.user.username,
                password: password // Note: In a real app, you wouldn't store the password
            )
            
            // Set current user
            User.currentUser = user
            isAuthenticated = true
            
        } catch NetworkError.unauthorized {
            errorMessage = "Неверный email или пароль"
        } catch {
            errorMessage = "Ошибка при входе: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
} 