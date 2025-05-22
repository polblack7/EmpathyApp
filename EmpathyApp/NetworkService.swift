import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://localhost:8080/api"
    
    private init() {}
    
    func login(email: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.serverError("Invalid response")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200:
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            // Save token after successful login
            TokenService.shared.saveToken(authResponse.token)
            return authResponse
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
    
    func register(email: String, username: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let registerRequest = RegisterRequest(email: email, username: username, password: password)
        request.httpBody = try JSONEncoder().encode(registerRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 201:
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            // Save token after successful registration
            TokenService.shared.saveToken(authResponse.token)
            return authResponse
        case 400:
            throw NetworkError.serverError("Invalid request data")
        default:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
    
    func validateToken() async throws -> Bool {
        guard let token = TokenService.shared.getToken() else {
            return false
        }
        
        let url = URL(string: "\(baseURL)/auth/validate")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200:
            
            return true
        case 401:
            TokenService.shared.deleteToken()
            return false
        default:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
    
    func getProfile() async throws -> User {
        guard let token = TokenService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
                guard let url = URL(string: "\(baseURL)/user/me") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(User.self, from: data)
        case 401:
            TokenService.shared.deleteToken()
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
    
    func updateProfile(username: String, newPassword: String? = nil) async throws -> User {
        guard let token = TokenService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/user/me") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updateRequest = UpdateUserRequest(username: username, newPassword: newPassword)
        request.httpBody = try JSONEncoder().encode(updateRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200:
            return try JSONDecoder().decode(User.self, from: data)
        case 401:
            TokenService.shared.deleteToken()
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Lobby Methods
    
    func createLobby() async throws -> Lobby {
        guard let token = TokenService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/lobbies") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 201:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Lobby.self, from: data)
        case 401:
            TokenService.shared.deleteToken()
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
    
    func joinLobby(code: String) async throws -> Lobby {
        guard let token = TokenService.shared.getToken() else {
            throw NetworkError.unauthorized
        }
        
        guard let url = URL(string: "\(baseURL)/lobbies/\(code)/join") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        switch httpResponse.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Lobby.self, from: data)
        case 401:
            TokenService.shared.deleteToken()
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.serverError("Лобби не найдено")
        default:
            throw NetworkError.serverError("Ошибка сервера: \(httpResponse.statusCode)")
        }
    }
} 
