import SwiftUI

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
            VStack(spacing: 0) {
                // Chat Info
                VStack(spacing: 8) {
                    Text("Чат \(viewModel.chat.id.uuidString.prefix(8))")
                        .font(.headline)
                    Text(viewModel.chat.createdAt, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Messages List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message) { card in
                                selectedCard = card
                            }
                        }
                    }
                    .padding()
                }
                
                // Cards Section
                VStack(spacing: 12) {
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
                                        .background(viewModel.selectedCategory == category ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(viewModel.selectedCategory == category ? .white : .primary)
                                        .cornerRadius(20)
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
                    }
                    .frame(height: 200)
                }
                .background(Color(.systemGray6))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showNewCardSheet = true
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        
                        Button("Покинуть") {
                            viewModel.leaveChat()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showNewCardSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("Новая карточка")) {
                            TextField("Название", text: $newCardTitle)
                            TextField("Описание", text: $newCardDescription)
                            
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
                                    .fill(Color.white)
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
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                                            .fill(Color(red: 0.6, green: 0.87, blue: 0.45))
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
                    .background(Color.white)
                    .multilineTextAlignment(.center)
                // Описание карточки
                ZStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(red: 0.6, green: 0.87, blue: 0.45))
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
            .background(Color.white)
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.black, lineWidth: 2)
            )
            .shadow(radius: 4)
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
                    .background(message.senderId == User.currentUser?.id ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.senderId == User.currentUser?.id ? .white : .primary)
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
