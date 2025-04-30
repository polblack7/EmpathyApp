import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @State private var showProfile = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Welcome message
                VStack(spacing: 10) {
                    Text("Добро пожаловать!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let username = User.currentUser?.username {
                        Text(username)
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 20)
                
                // Join Chat Section
                VStack(spacing: 15) {
                    Text("Присоединиться к чату")
                        .font(.headline)
                    
                    TextField("ID чата", text: $viewModel.joinChatID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    Button(action: {
                        viewModel.joinChat()
                    }) {
                        Text("Присоединиться")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.joinChatID.isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Create Chat Section
                VStack(spacing: 15) {
                    Text("Создать новый чат")
                        .font(.headline)
                    
                    Button(action: {
                        viewModel.createChat()
                    }) {
                        Text("Создать лобби")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Главная", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(
                            destination: ProfileView(),
                            isActive: $showProfile
                        ) {
                            Button(action: {
                                showProfile = true
                            }) {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                            }
                        }
                        
                        Button(action: {
                            authManager.logout()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title2)
                        }
                    }
                }
            }
            .background(
                NavigationLink(
                    destination: ChatView(viewModel: ChatViewModel(chat: viewModel.activeChat ?? Chat(participants: []))),
                    isActive: Binding(
                        get: { viewModel.activeChat != nil },
                        set: { if !$0 { viewModel.activeChat = nil } }
                    )
                ) {
                    EmptyView()
                }
            )
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthManager())
} 