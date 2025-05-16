import Foundation
import SwiftUI
import UIKit

class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var username: String
    @Published var password: String = ""
    @Published var avatarImage: UIImage?
    @Published var categories: [String]
    @Published var newCategoryName: String = ""
    @Published var showImagePicker: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var errorMessage: String = ""
    
    // Statistics
    var chatsCount: Int
    var cardsCount: Int
    var messagesCount: Int
    
    init() {
        // Initialize with current user data
        if let user = User.currentUser {
            self.username = user.username
            self.categories = user.categories
            self.chatsCount = user.chatsCount
            self.cardsCount = user.cardsCount
            self.messagesCount = user.messagesCount
        } else {
            // Fallback values if no user is logged in
            self.username = ""
            self.categories = []
            self.chatsCount = 0
            self.cardsCount = 0
            self.messagesCount = 0
        }
        
        // Load profile data from server
        Task {
            await loadProfile()
        }
    }
    
    // MARK: - Profile Management
    @MainActor
    func loadProfile() async {
        do {
            let user = try await NetworkService.shared.getProfile()
            self.username = user.username
            self.categories = user.categories
            self.chatsCount = user.chatsCount
            self.cardsCount = user.cardsCount
            self.messagesCount = user.messagesCount
            UserManager.shared.updateUser(user)
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func saveChanges() async {
        do {
            let updatedUser = try await NetworkService.shared.updateProfile(
                username: username,
                newPassword: password.isEmpty ? nil : password
            )
            
            // Update user through UserManager
            UserManager.shared.updateUser(updatedUser)
            
            // Clear password field
            password = ""
            
            // Show success alert
            showSuccessAlert = true
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
    }
    
    func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        // Check if category already exists
        guard !categories.contains(newCategoryName) else {
            return
        }
        
        // Add new category
        categories.append(newCategoryName)
        
        // Update current user
        if let currentUser = User.currentUser {
            var updatedUser = currentUser
            updatedUser.categories = categories
            updatedUser.cardsCount += 1 // Increment cards count
            User.currentUser = updatedUser
        }
        
        // Clear input field
        newCategoryName = ""
    }
    
    func changeAvatar() {
        showImagePicker = true
    }
    
    func updateAvatar(_ image: UIImage) {
        // Resize image to a reasonable size for avatar
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        // Update avatar
        self.avatarImage = resizedImage
        
        // Update current user
        if let currentUser = User.currentUser {
            var updatedUser = currentUser
            // In a real app, you would save the image to storage and store its URL
            // For now, we'll just update the local state
            User.currentUser = updatedUser
        }
        
        showSuccessAlert = true
    }
} 
