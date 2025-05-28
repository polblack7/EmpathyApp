import Foundation

class WebSocketService: NSObject, URLSessionWebSocketDelegate {
    static let shared = WebSocketService()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    private var reconnectTimer: Timer?
    private let reconnectInterval: TimeInterval = 5.0
    
    private override init() {
        super.init()
    }
    
    func connect(to chatId: String) {
        guard let token = TokenService.shared.getToken(),
              let url = URL(string: "ws://45.149.63.247:8080/ws/chats/\(chatId)?token=\(token)") else {
            print("Invalid WebSocket URL or no token found")
            return
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    func sendMessage(_ message: ChatCardRequest) {
        guard isConnected else {
            print("WebSocket is not connected")
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(message)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("Error converting data to string")
                return
            }
            print("Sending message: \(jsonString)")
            let message = URLSessionWebSocketTask.Message.string(jsonString)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    print("Message sent successfully")
                }
            }
        } catch {
            print("Error encoding message: \(error.localizedDescription)")
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.handleReceivedData(data)
                case .string(let string):
                    if let data = string.data(using: .utf8) {
                        self?.handleReceivedData(data)
                    }
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("Error receiving message: \(error)")
                self?.handleDisconnection()
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            let message = try decoder.decode(ChatMessageResponse.self, from: data)
            print("Received message: \(message)")
            NotificationCenter.default.post(name: .newChatMessage, object: message)
        } catch {
            print("Error decoding message: \(error.localizedDescription)")
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw message data: \(jsonString)")
            }
        }
    }
    
    private func handleDisconnection() {
        isConnected = false
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectInterval, repeats: true) { [weak self] _ in
            self?.attemptReconnect()
        }
    }
    
    private func attemptReconnect() {
        guard let webSocketTask = webSocketTask else { return }
        webSocketTask.resume()
        receiveMessage()
    }
    
    // MARK: - URLSessionWebSocketDelegate
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        print("WebSocket connected")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        handleDisconnection()
        print("WebSocket disconnected with code: \(closeCode)")
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let newChatMessage = Notification.Name("newChatMessage")
}

// MARK: - Request/Response Models
struct ChatCardRequest: Codable {
    let title: String
    let description: String
}

struct ChatMessageResponse: Codable {
    let id: UUID
    let chatId: String
    let senderId: String
    let card: CardDto
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId
        case senderId
        case card
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        chatId = try container.decode(String.self, forKey: .chatId)
        senderId = try container.decode(String.self, forKey: .senderId)
        card = try container.decode(CardDto.self, forKey: .card)
        
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestampString) {
            timestamp = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Invalid date format")
        }
    }
}

struct CardDto: Codable {
    let title: String
    let description: String
} 
