import SwiftUI
import UIKit

class AvatarStorageService {
    static let shared = AvatarStorageService()
    private let avatarKey = "userAvatarImage"
    
    private init() {}
    
    func saveAvatar(image: UIImage?) {
        if let image = image, let imageData = image.pngData() {
            UserDefaults.standard.set(imageData, forKey: avatarKey)
        } else {
            UserDefaults.standard.removeObject(forKey: avatarKey)
        }
    }
    
    func loadAvatar() -> UIImage? {
        if let imageData = UserDefaults.standard.data(forKey: avatarKey) {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }
    
    func deleteAvatar() {
        UserDefaults.standard.removeObject(forKey: avatarKey)
    }
} 