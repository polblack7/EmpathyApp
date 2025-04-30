import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    
    // MARK: - Validation Methods
    private func validateInput() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    // MARK: - Login Method
    func login() {
        // Reset error message
        errorMessage = ""
        
        // Find user by email
        guard let user = User.allUsers.first(where: { $0.email == email }) else {
            errorMessage = "Пользователь не найден"
            return
        }
        
        // Check password
        guard user.password == password else {
            errorMessage = "Неверный пароль"
            return
        }
        
        // Set current user
        User.currentUser = user
        isAuthenticated = true
    }
} 