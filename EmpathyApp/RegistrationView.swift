import SwiftUI



struct RegistrationView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = RegistrationViewModel()
    @EnvironmentObject private var authManager: AuthManager
    
    // Same gradient palette as LoginView
    private let gradientColors = [
        Color(red: 0.98, green: 0.24, blue: 0.64),   // Flo‑like pink
        Color(red: 0.55, green: 0.19, blue: 0.96)    // Flo‑like purple
    ]
    
    // Focus handling
    @FocusState private var focusedField: Field?
    private enum Field {
        case email, username, password, confirm
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: gradientColors,
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 32) {
                    
                    // Title
                    Text("Регистрация")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: gradientColors,
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .padding(.bottom, 20)
                    
                    // Input fields
                    VStack(spacing: 20) {
                        
                        TextField("Email", text: $viewModel.email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .foregroundColor(.black)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .email)
                            .onTapGesture { focusedField = .email }
                        
                        TextField("Имя пользователя", text: $viewModel.username)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .foregroundColor(.black)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .username)
                            .onTapGesture { focusedField = .username }
                        
                        SecureField("Пароль", text: $viewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .foregroundColor(.black)
                            .textContentType(.newPassword)
                            .focused($focusedField, equals: .password)
                            .onTapGesture { focusedField = .password }
                        
                        SecureField("Подтверждение пароля", text: $viewModel.confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .foregroundColor(.black)
                            .textContentType(.newPassword)
                            .focused($focusedField, equals: .confirm)
                            .onTapGesture { focusedField = .confirm }
                        
                        // Error message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Register button
                        Button(action: {
                            Task {
                                if await viewModel.register() {
                                    authManager.login()          // mark user as authenticated
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Зарегистрироваться")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .fontWeight(.semibold)
                            }
                        }
                        .background(
                            LinearGradient(colors: gradientColors,
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(viewModel.email.isEmpty ||
                                  viewModel.username.isEmpty ||
                                  viewModel.password.isEmpty ||
                                  viewModel.confirmPassword.isEmpty ||
                                  viewModel.isLoading)
                        .opacity((viewModel.email.isEmpty ||
                                  viewModel.username.isEmpty ||
                                  viewModel.password.isEmpty ||
                                  viewModel.confirmPassword.isEmpty ||
                                  viewModel.isLoading) ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
            }
        }
        
        
        
    }
}

#Preview {
    RegistrationView()
}
