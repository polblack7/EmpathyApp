import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let user: UserResponse
}

struct UserResponse: Codable {
    let id: String
    let email: String
    let username: String
}


