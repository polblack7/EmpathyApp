import SwiftUI

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = RegistrationViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Регистрация")) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Имя пользователя", text: $viewModel.username)
                        .autocapitalization(.none)
                    
                    SecureField("Пароль", text: $viewModel.password)
                        .textContentType(.newPassword)
                    
                    SecureField("Подтверждение пароля", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        if viewModel.register() {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Зарегистрироваться")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationTitle("Регистрация")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    RegistrationView()
} 