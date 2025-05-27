import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var userManager = UserManager.shared
    @EnvironmentObject private var authManager: AuthManager
    @State private var showingLobbyView = false
    @State private var displayedAvatar: UIImage? // State variable to hold the avatar image
    
    // Palette identical to Login / Registration
    private let gradientColors = [
        Color(red: 0.75, green: 0.75, blue: 0.95),   // More vibrant lavender
        Color(red: 0.65, green: 0.75, blue: 0.95)    // More vibrant blue
    ]
    
    var body: some View {
        NavigationView { // Wrap content in NavigationView
            VStack(spacing: 24) {
                
                Text("EmpathyApp")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: gradientColors,
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .padding(.bottom, 40)
                
                Spacer().frame(height: 60)

                // Аватар пользователя
                VStack(spacing: 12) {
                    if let avatar = displayedAvatar { // Use the state variable here
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.95)) // Use color from gradient
                    }
                    
                    // Имя профиля
                    Text(userManager.currentUser?.username ?? "Имя пользователя")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }

                // Кнопка: Просмотр профиля
                NavigationLink(destination: ProfileView()) { // Correctly use NavigationLink
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.95)) // Use color from gradient
                        Text("Просмотреть профиль")
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                }
                .padding(.horizontal)

                // Кнопка: Выход из аккаунта
                Button(action: {
                    authManager.logout() // Connect to logout action
                }) {
                    HStack {
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.95)) // Use color from gradient
                        Text("Выйти из аккаунта")
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                }
                .padding(.horizontal)

                Spacer()

                // Кнопка: Управление лобби
                Button(action: {
                    showingLobbyView = true // Set state to show LobbyView
                }) {
                    Text("Управление лобби")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: gradientColors,
                                           startPoint: .leading,
                                           endPoint: .trailing) // Use gradient for background
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingLobbyView) {
                LobbyView()
            }
            .navigationBarHidden(true) // Hide the navigation bar if you don't want the default one
            .onAppear { // Load avatar and refresh user data when the view appears
                displayedAvatar = AvatarStorageService.shared.loadAvatar()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AuthManager())
    }
}
