import SwiftUI

struct LobbyView: View {
    @StateObject private var viewModel = LobbyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
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
                        .background(Color.blue)
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
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(viewModel.lobbyCode.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                
                if let lobby = viewModel.currentLobby {
                    VStack(spacing: 10) {
                        Text("Текущее лобби")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Код: \(lobby.id)")
                            .font(.headline)
                        
                        Text("Создано: \(lobby.createdAt.formatted(.dateTime))")
                            .font(.subheadline)
                        
                        Text("Участников: \(lobby.participants.count)")
                            .font(.subheadline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                
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
}

#Preview {
    LobbyView()
} 