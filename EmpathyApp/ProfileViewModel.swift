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
    @Published var showSuccessAlert: Bool = false
    
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
    }
    
    // MARK: - Profile Management
    func saveChanges() {
        guard let currentUser = User.currentUser else { return }
        
        // Create a mutable copy of the user
        var updatedUser = currentUser
        
        // Update username if changed
        if currentUser.username != username {
            updatedUser.username = username
        }
        
        // Update password if changed
        if !password.isEmpty {
            // updatedUser.password = password
        }
        
        // Update categories
        updatedUser.categories = categories
        
        // Update current user
        User.currentUser = updatedUser
        
        // Update in all users list
        if let index = User.allUsers.firstIndex(where: { $0.id == currentUser.id }) {
            User.allUsers[index] = updatedUser
        }
        
        // Show success alert
        showSuccessAlert = true
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
            
            // Update in all users list
            if let index = User.allUsers.firstIndex(where: { $0.id == currentUser.id }) {
                User.allUsers[index] = updatedUser
            }
        }
        
        // Clear input field
        newCategoryName = ""
    }
    
    func changeAvatar() {
        // Placeholder for avatar change logic
        // In a real app, this would open UIImagePickerController
        print("Avatar change requested")
    }
} 
