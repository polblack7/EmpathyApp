import SwiftUI

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

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    init() {
        // Check if user is already logged in
        isAuthenticated = User.currentUser != nil
    }
    
    func login() {
        isAuthenticated = true
    }
    
    func logout() {
        User.currentUser = nil
        isAuthenticated = false
    }
}
