import Foundation

class CountersStorageService {
    static let shared = CountersStorageService()
    private let sentCardsKey = "sentCardsCount"
    private let chatsCountKey = "chatsCount"
    
    private init() {}
    
    func incrementSentCardsCount() {
        let currentCount = UserDefaults.standard.integer(forKey: sentCardsKey)
        UserDefaults.standard.set(currentCount + 1, forKey: sentCardsKey)
    }
    
    func incrementChatsCount() {
        let currentCount = UserDefaults.standard.integer(forKey: chatsCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: chatsCountKey)
    }
    
    func getSentCardsCount() -> Int {
        return UserDefaults.standard.integer(forKey: sentCardsKey)
    }
    
    func getChatsCount() -> Int {
        return UserDefaults.standard.integer(forKey: chatsCountKey)
    }
    
    func resetCounters() {
        UserDefaults.standard.removeObject(forKey: sentCardsKey)
        UserDefaults.standard.removeObject(forKey: chatsCountKey)
    }
} 