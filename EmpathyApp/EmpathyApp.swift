import SwiftUI
import JWTDecode

@main
struct EmpathyApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainView()
                        .environmentObject(authManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                }
            }
            .preferredColorScheme(.light)
        }
    }
}

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    private func checkAuthStatus() async {
        // Get token from storage
        guard let token = TokenService.shared.getToken() else {
            LogService.shared.info("No token found")
            return
        }
        
        // Try to decode token
        guard let decodedToken = JWTToken.decode(token) else {
            LogService.shared.error("Failed to decode token")
            TokenService.shared.deleteToken()
            return
        }
        
        // Check if token is expired
        guard !decodedToken.isExpired else {
            LogService.shared.info("Token is expired")
            TokenService.shared.deleteToken()
            return
        }
        
        // Create user from token data
        let user = User(
            id: UUID(uuidString: decodedToken.sub) ?? UUID(),
            email: decodedToken.email,
            username: decodedToken.username
        )
        
        // Set current user
        User.currentUser = user
        LogService.shared.info("User authenticated: \(user.username)")
        
        // Mark as authenticated
        isAuthenticated = true
    }
    
    func login() {
        isAuthenticated = true
    }
    
    func logout() {
        TokenService.shared.deleteToken()
        User.currentUser = nil
        AvatarStorageService.shared.deleteAvatar()
        isAuthenticated = false
    }
}
