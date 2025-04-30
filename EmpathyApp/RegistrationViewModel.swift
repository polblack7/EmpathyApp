import Foundation
import SwiftUI

class RegistrationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    @Published var isRegistrationSuccessful: Bool = false
    
    // MARK: - Validation Methods
    private func validateEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword() -> Bool {
        return password.count >= 6
    }
    
    private func validateUsername() -> Bool {
        return username.count >= 3
    }
    
    // MARK: - Registration Method
    func register() -> Bool {
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
            errorMessage = "Имя пользователя должно содержать минимум 3 символа"
            return false
        }
        
        // Validate password
        guard !password.isEmpty else {
            errorMessage = "Пароль не может быть пустым"
            return false
        }
        
        guard validatePassword() else {
            errorMessage = "Пароль должен содержать минимум 6 символов"
            return false
        }
        
        // Check password confirmation
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            return false
        }
        
        // Check if user already exists
        if User.allUsers.contains(where: { $0.email == email }) {
            errorMessage = "Пользователь с таким email уже существует"
            return false
        }
        
        // Create new user
        let newUser = User(
            email: email,
            username: username,
            password: password
        )
        
        // Add user to all users list
        User.allUsers.append(newUser)
        
        // Set current user
        User.currentUser = newUser
        
        isRegistrationSuccessful = true
        return true
    }
} 