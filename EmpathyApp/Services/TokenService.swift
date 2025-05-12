import Foundation
import Security



class TokenService {
    static let shared = TokenService()
    private let tokenKey = "authToken"
    
    private init() {}
    
    func saveToken(_ token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: token.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // First try to delete any existing token
        SecItemDelete(query as CFDictionary)
        
        // Then add the new token
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Error saving token: \(status)")
            return
        }
        
        // Update current user from token
        updateCurrentUser(from: token)
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
        User.currentUser = nil
    }
    
    func getDecodedToken() -> JWTToken? {
        guard let token = getToken() else { return nil }
        return JWTToken.decode(token)
        
    }
    
    private func updateCurrentUser(from token: String) {
        guard let decodedToken = JWTToken.decode(token) else { return }
        
        let user = User(
            id: UUID(uuidString: decodedToken.sub) ?? UUID(),
            email: decodedToken.email,
            username: decodedToken.username
        )
        
        User.currentUser = user
    }
} 
