import SwiftUI



struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var authManager: AuthManager
    
    @FocusState private var focusedField: Field?
    private enum Field {
        case email
        case password
    }
    
    private let gradientColors = [
        Color(red: 0.98, green: 0.24, blue: 0.64),   // Flo‑like pink
        Color(red: 0.55, green: 0.19, blue: 0.96)    // Flo‑like purple
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: gradientColors,
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            NavigationView {
                VStack(spacing: 32) {
                    
                    // Logo / App name
                    Text("EmpathyApp")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: gradientColors,
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .padding(.bottom, 40)
                    
                    // Login form
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
                        
                        SecureField("Пароль", text: $viewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .foregroundColor(.black)
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                            .onTapGesture { focusedField = .password }
                        
                        // Error message
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        // Primary login button
                        Button(action: {
                            viewModel.login()
                            if viewModel.isAuthenticated {
                                authManager.login()
                            }
                        }) {
                            Text("Войти")
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
                        .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                        .opacity(viewModel.email.isEmpty || viewModel.password.isEmpty ? 0.6 : 1.0)
                        
                        // Registration link (full‑width tap area)
                        NavigationLink(destination: RegistrationView()) {
                            HStack(spacing: 4) {
                                Text("Нет аккаунта?")
                                    .foregroundColor(.black)
                                Text("Зарегистрируйтесь")
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(colors: gradientColors,
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                    )
                            }
                            .font(.footnote)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        
                        
                        
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                }
                .padding()
                .navigationBarHidden(true)
            }
        }
        
        
    }
    
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
