import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        Form {
            // Avatar Section
            Section(header: Text("Аватар")) {
                HStack {
                    Spacer()
                    if let avatar = viewModel.avatarImage {
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical)
                
                Button(action: {
                    viewModel.changeAvatar()
                }) {
                    Text("Изменить аватар")
                        .frame(maxWidth: .infinity)
                }
            }
            
            // User Data Section
            Section(header: Text("Данные пользователя")) {
                TextField("Имя пользователя", text: $viewModel.username)
                SecureField("Новый пароль", text: $viewModel.password)
            }
            
            // Theme Section
            Section(header: Text("Настройки")) {
                Toggle("Тёмная тема", isOn: $isDarkMode)
            }
            
            // Statistics Section
            Section(header: Text("Статистика")) {
                HStack {
                    Text("Чатов")
                    Spacer()
                    Text("\(viewModel.chatsCount)")
                }
                HStack {
                    Text("Карточек")
                    Spacer()
                    Text("\(viewModel.cardsCount)")
                }
                HStack {
                    Text("Сообщений")
                    Spacer()
                    Text("\(viewModel.messagesCount)")
                }
            }
            
            // Categories Section
            Section(header: Text("Категории эмоций")) {
                ForEach(viewModel.categories, id: \.self) { category in
                    Text(category)
                }
                
                HStack {
                    TextField("Новая категория", text: $viewModel.newCategoryName)
                    Button(action: {
                        viewModel.addCategory()
                    }) {
                        Text("Добавить")
                    }
                    .disabled(viewModel.newCategoryName.isEmpty)
                }
            }
        }
        .navigationTitle("Профиль")
        .navigationBarItems(trailing: Button("Сохранить") {
            viewModel.saveChanges()
        })
        .alert("Изменения сохранены", isPresented: $viewModel.showSuccessAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
} 