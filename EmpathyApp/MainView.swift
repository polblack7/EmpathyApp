import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var userManager = UserManager.shared
    @EnvironmentObject private var authManager: AuthManager
    @FocusState private var focusedField: Field?
    private enum Field {
        case chatID
    }
    
    // Palette identical to Login / Registration
    private let gradientColors = [
        Color(red: 0.75, green: 0.75, blue: 0.95),   // More vibrant lavender
        Color(red: 0.65, green: 0.75, blue: 0.95)    // More vibrant blue
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: gradientColors,
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            NavigationView {
                VStack {
                    // User Avatar
                    VStack(spacing: 6) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(
                                LinearGradient(colors: gradientColors,
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                        
                        if let username = userManager.currentUser?.username {
                            Text(username)
                                .font(.title3)
                                .foregroundColor(.black.opacity(0.9))
                        }
                    }
                    .padding(.top, 12)
                    
                    .padding(.bottom, 80)
                    // Join Chat Section
                    VStack(spacing: 18) {
                        Text("Присоединиться к чату")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        TextField("ID чата", text: $viewModel.joinChatID)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .chatID)
                            .onTapGesture { focusedField = .chatID }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                        
                        Button(action: {
                            viewModel.joinChat()
                        }) {
                            Text("Присоединиться")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .fontWeight(.semibold)
                        }
                        .background(
                            LinearGradient(colors: gradientColors,
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(viewModel.joinChatID.isEmpty)
                        .opacity(viewModel.joinChatID.isEmpty ? 0.6 : 1)
                    }
                    .padding(.horizontal, 28)
                    
                    
                    Spacer()
                    
                    // Create Chat Section
                    VStack(spacing: 16) {
                        Button(action: {
                            viewModel.createChat()
                        }) {
                            Text("Создать лобби")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .fontWeight(.semibold)
                        }
                        .background(
                            LinearGradient(colors: gradientColors,
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .navigationBarTitle("Главная", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 24) {
                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.circle")
                                    .font(.title2)
                                    .foregroundColor(gradientColors.first)
                            }
                            Button(action: { authManager.logout() }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        .foregroundColor(.white)
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
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthManager())
}
