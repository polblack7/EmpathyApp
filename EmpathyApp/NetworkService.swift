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
        let url = URL(string: "\(baseURL)/auth/login")!
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
            return try JSONDecoder().decode(AuthResponse.self, from: data)
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
            return try JSONDecoder().decode(AuthResponse.self, from: data)
        case 400:
            throw NetworkError.serverError("Invalid request data")
        default:
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
} 