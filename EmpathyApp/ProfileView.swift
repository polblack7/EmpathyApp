import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showImagePicker = false
   
    
    // Shared gradient palette
    private let gradientColors = [
        Color(red: 0.75, green: 0.75, blue: 0.95),   // More vibrant lavender
        Color(red: 0.65, green: 0.75, blue: 0.95)    // More vibrant blue
    ]
    
    // Brighter gradient for primary action buttons
    private let buttonGradientColors = [
        Color(red: 0.75, green: 0.75, blue: 0.95),   // More vibrant lavender
        Color(red: 0.65, green: 0.75, blue: 0.95)    // More vibrant blue
    ]
    
    // Focus handling
    @FocusState private var focusedField: Field?
    @State private var isFormDirty: Bool = false
    @Environment(\.presentationMode) private var presentationMode
    private enum Field {
        case username, newCategory
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(colors: gradientColors,
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // Avatar
                    VStack(spacing: 12) {
                        if let avatar = viewModel.avatarImage {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Button("Изменить аватар") {
                            viewModel.changeAvatar()
                        }
                        .font(.footnote)
                        .foregroundColor(.black)
                    }
                    .padding(.top, 20)
                    
                    // User fields
                    VStack(spacing: 20) {
                        TextField("Имя пользователя", text: $viewModel.username)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                            .focused($focusedField, equals: .username)
                            .onTapGesture { focusedField = .username }
                            .onChange(of: viewModel.username) { _ in isFormDirty = true }
                        
                        SecureField("Новый пароль", text: $viewModel.password)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                            .onChange(of: viewModel.password) { _ in isFormDirty = true }
                    }
                    .padding(.horizontal, 32)
                    
                    
                    
                    // Stats
                    VStack(spacing: 8) {
                        statRow("Чатов", viewModel.chatsCount)
                        statRow("Карточек", viewModel.cardsCount)
                        
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    
                    // Categories
                    
                    
                    // Save button
                    Button(action: {
                        viewModel.saveChanges()
                        isFormDirty = false       // reset state after saving
                        presentationMode.wrappedValue.dismiss()   // navigate back to MainView
                    }) {
                        Text("Сохранить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Color(.systemGray3)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                    .disabled(!isFormDirty)
                    .opacity(isFormDirty ? 1 : 0.6)
                    
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitle("Профиль", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()   // return to MainView
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Главная")
                        }
                    }
                    .foregroundColor(.black)
                }
            }
            .alert("Изменения сохранены", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) { }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: Binding(
                    get: { viewModel.avatarImage ?? UIImage() },
                    set: { newImage in
                        if let image = newImage {
                            viewModel.updateAvatar(image)
                        }
                    }
                ))
            }
        }
        
    }
    
    // Helper for stats rows
    private func statRow(_ title: String, _ value: Int) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
        }
        .foregroundColor(.black)   // small text → black
        .font(.footnote)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
