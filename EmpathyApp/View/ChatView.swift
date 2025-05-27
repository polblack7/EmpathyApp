import SwiftUI

// Фирменный градиент приложения (розовый → фиолетовый)
private let floGradient = LinearGradient(
    colors: [
        Color(red: 0.75, green: 0.75, blue: 0.95),   // More vibrant lavender
        Color(red: 0.65, green: 0.75, blue: 0.95)    // More vibrant blue
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing)

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showNewCardSheet = false
    @State private var newCardTitle = ""
    @State private var newCardDescription = ""
    @State private var newCardCategory = ""
    @State private var newCardImage: UIImage?
    @State private var showImagePicker = false
    @State private var selectedCard: Card? = nil
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack(spacing: 0) {
                
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message) { card in
                                    selectedCard = card
                                }
                                .id(message.id) // идентификатор для прокрутки к сообщению
                            }
                        }
                        .padding()
                    }
                    // Прокрутка к последнему сообщению при открытии экрана
                    .onAppear {
                        if let last = viewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                    // Прокрутка к последнему сообщению при каждом новом сообщении
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Cards Section
                VStack(spacing: 6) {
                    // Scrollable Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.categories.keys.sorted(), id: \.self) { category in
                                Button(action: {
                                    viewModel.selectedCategory = category
                                }) {
                                    Text(category)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedCategory == category
                                                    ? AnyShapeStyle(floGradient)
                                                    : AnyShapeStyle(Color(.systemGray5)))
                                        .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 44)
                    
                    
                    
                    // Cards Grid
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(viewModel.categories[viewModel.selectedCategory] ?? [], id: \.id) { card in
                                CardView(card: card) {
                                    viewModel.sendCard(card)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 22)
                    }
                    .frame(height: 230)
                    
                }
                
                
            }
            .font(.custom("AvenirNextRounded-Regular", size: 17))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // "Плюс" — слева
                

                // "Покинуть" — справа
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.leaveLobby()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                // Handle error (e.g., show error message to user)
                                print("Error leaving lobby: \(error)")
                            }
                        }
                    }) {
                        Text("Покинуть")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(floGradient)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }

                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text("Чат \(viewModel.chat.lobbyId)")
                            .font(.headline)
                            .foregroundStyle(floGradient)
                        Text(viewModel.chat.createdAt, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showNewCardSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("Новая карточка")) {
                            TextField("Название", text: $newCardTitle)
                                .background(Color(.systemGray5))
                            TextField("Описание", text: $newCardDescription)
                                .background(Color(.systemGray5))
                            
                            if let image = newCardImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Text(newCardImage == nil ? "Добавить изображение" : "Изменить изображение")
                            }
                            
                            Picker("Категория", selection: $newCardCategory) {
                                ForEach(viewModel.categories.keys.sorted(), id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                        }
                    }
                    .navigationTitle("Новая карточка")
                    .navigationBarItems(
                        leading: Button("Отмена") {
                            showNewCardSheet = false
                            newCardTitle = ""
                            newCardDescription = ""
                            newCardCategory = ""
                            newCardImage = nil
                        },
                        trailing: Button("Добавить") {
                            viewModel.addCustomCard(
                                title: newCardTitle,
                                description: newCardDescription,
                                image: newCardImage,
                                category: newCardCategory
                            )
                            newCardTitle = ""
                            newCardDescription = ""
                            newCardCategory = ""
                            newCardImage = nil
                            showNewCardSheet = false
                        }
                        .disabled(newCardTitle.isEmpty || newCardDescription.isEmpty || newCardCategory.isEmpty)
                    )
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $newCardImage)
            }
            // (Title/date overlay removed)
            // Кастомный overlay для просмотра карточки
            .overlay(
                Group {
                    if let card = selectedCard {
                        Color.black.opacity(0.25)
                            .ignoresSafeArea()
                            .onTapGesture { selectedCard = nil }
                        VStack {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                VStack(spacing: 0) {
                                    Text(card.title)
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, minHeight: 60)
                                        .background(Color.white)
                                        .multilineTextAlignment(.center)
                                        .cornerRadius(32)
                                        .padding(10)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                                            .fill(floGradient)
                                        ScrollView {
                                            Text(card.description)
                                                .foregroundColor(.white)
                                                .font(.title3)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 320)
                                }
                                .frame(width: 320, height: 380)
                            }
                            .padding()
                            Spacer()
                            Button("Закрыть") {
                                selectedCard = nil
                            }
                            .font(.title2)
                            .padding(.bottom, 40)
                        }
                        .transition(.opacity)
                    }
                }, alignment: .center
            )
        }
    }
}

struct CardView: View {
    let card: Card
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Название карточки
                Text(card.title)
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.white.opacity(0.0))
                    .multilineTextAlignment(.center)
                    .padding(10)
                    
                // Описание карточки
                ZStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(floGradient)
                        .frame(maxWidth: .infinity)
                    Text(card.description)
                        .foregroundColor(.white)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            }
            .frame(width: 220, height: 220)
            .background(.ultraThinMaterial)
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 2)
            )
            
        }
        .buttonStyle(PlainButtonStyle())
        
    }
}

struct MessageBubble: View {
    let message: Message
    var onCardTap: (Card) -> Void = { _ in }
    
    var body: some View {
        HStack {
            if message.senderId == User.currentUser?.id {
                Spacer()
            }
            
            if let card = message.card {
                CardView(card: card, onTap: { onCardTap(card) })
                    .padding(.vertical, 4)
            } else {
                Text(message.text)
                    .padding()
                    .background(AnyShapeStyle(floGradient))
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            
            if message.senderId != User.currentUser?.id {
                Spacer()
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NavigationView {
        ChatView(viewModel: ChatViewModel(chat: Chat(participants: [])))
    }
}
