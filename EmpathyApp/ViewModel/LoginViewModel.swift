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
    
    private let log = LogService.shared
    
    // MARK: - Validation Methods
    private func validateInput() -> Bool {
        let isValid = !email.isEmpty && !password.isEmpty
        log.debug("Input validation: \(isValid ? "passed" : "failed")")
        return isValid
    }
    
    // MARK: - Login Method
    func login() async {
        log.info("Starting login process for email: \(email)")
        
        // Reset error message
        errorMessage = ""
        isLoading = true
        
        do {
            log.debug("Attempting to login via API")
            let response = try await NetworkService.shared.login(email: email, password: password)
            
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
            
            log.info("Login successful for user: \(response.user.username)")
            isAuthenticated = true
            
        } catch NetworkError.unauthorized {
            log.error("Login failed: Unauthorized access attempt")
            errorMessage = "Неверный email или пароль"
        } catch {
            log.error("Login failed with error", error: error)
            errorMessage = "Ошибка при входе: \(error.localizedDescription)"
        }
        
        isLoading = false
        log.debug("Login process completed. Success: \(isAuthenticated)")
    }
} 
