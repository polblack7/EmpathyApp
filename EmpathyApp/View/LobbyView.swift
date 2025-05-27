import SwiftUI

// Shared gradient palette
private let gradientColors = [
    Color(red: 0.75, green: 0.75, blue: 0.95),   // More vibrant lavender
    Color(red: 0.65, green: 0.75, blue: 0.95)    // More vibrant blue
]

struct LobbyView: View {
    @StateObject private var viewModel = LobbyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack { // Wrap in ZStack for background
            // Background
            LinearGradient(colors: gradientColors,
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 20) {
                    // Create Lobby Section
                    VStack(spacing: 15) {
                        Text("Создать новое лобби")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            Task {
                                await viewModel.createLobby()
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Создать лобби")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: gradientColors,
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.isLoading)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                    // Join Lobby Section
                    VStack(spacing: 15) {
                        Text("Присоединиться к лобби")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        TextField("Введите код лобби", text: $viewModel.lobbyCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.characters)
                            .padding(.horizontal)
                        
                        Button(action: {
                            Task {
                                await viewModel.joinLobby()
                            }
                        }) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                Text("Присоединиться")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: gradientColors,
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(viewModel.lobbyCode.isEmpty || viewModel.isLoading)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    
                    
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Лобби")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Закрыть") {
                            dismiss()
                        }
                    }
                }
                .alert("Ошибка", isPresented: .constant(viewModel.error != nil)) {
                    Button("OK") {
                        viewModel.clearError()
                    }
                } message: {
                    if let networkError = viewModel.error as? NetworkError {
                        switch networkError {
                        case .unauthorized:
                            Text("Необходима авторизация")
                        case .serverError(let message):
                            Text(message)
                        default:
                            Text("Произошла ошибка")
                        }
                    } else {
                        Text(viewModel.error?.localizedDescription ?? "Произошла ошибка")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.shouldNavigateToChat) {
            if let chat = viewModel.activeChat {
                NavigationView {
                    ChatView(viewModel: ChatViewModel(chat: chat))
                }
            }
        }
    }
}

#Preview {
    LobbyView()
} 
