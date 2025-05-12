import Foundation
import SwiftUI

@MainActor
class RegistrationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isRegistrationSuccessful: Bool = false
    @Published var isLoading: Bool = false
    
    // MARK: - Validation Methods
    private func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword() -> Bool {
        return password.count >= 8
    }
    
    private func validateUsername() -> Bool {
        return username.count >= 3 && username.count <= 50
    }
    
    // MARK: - Registration Method
    func register() async -> Bool {
        // Reset error message
        errorMessage = ""
        
        // Validate email
        guard !email.isEmpty else {
            errorMessage = "Email не может быть пустым"
            return false
        }
        
        guard validateEmail() else {
            errorMessage = "Введите корректный email"
            return false
        }
        
        // Validate username
        guard !username.isEmpty else {
            errorMessage = "Имя пользователя не может быть пустым"
            return false
        }
        
        guard validateUsername() else {
            errorMessage = "Имя пользователя должно содержать от 3 до 50 символов"
            return false
        }
        
        // Validate password
        guard !password.isEmpty else {
            errorMessage = "Пароль не может быть пустым"
            return false
        }
        
        guard validatePassword() else {
            errorMessage = "Пароль должен содержать минимум 8 символов"
            return false
        }
        
        // Check password confirmation
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            return false
        }
        
        isLoading = true
        
        do {
            let response = try await NetworkService.shared.register(
                email: email,
                username: username,
                password: password
            )
            
            // Store token
            TokenService.shared.saveToken(response.token)
            
            // Create user from response
            let user = User(
                id: UUID(uuidString: response.user.id) ?? UUID(),
                email: response.user.email,
                username: response.user.username
            )
            
            // Set current user
            User.currentUser = user
            
            isRegistrationSuccessful = true
            isLoading = false
            return true
            
        } catch NetworkError.serverError(let message) {
            errorMessage = message
        } catch {
            errorMessage = "Ошибка при регистрации: \(error.localizedDescription)"
        }
        
        isLoading = false
        return false
    }
} 