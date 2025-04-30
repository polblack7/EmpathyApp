import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showNewCardSheet = false
    @State private var newCardText = ""
    @State private var newCardCategory = ""
    
    var body: some View {
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
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Cards Section
            VStack(spacing: 12) {
                // Category Picker
                Picker("Категория", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories.keys.sorted(), id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Cards Grid
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(viewModel.categories[viewModel.selectedCategory] ?? [], id: \.self) { card in
                            Button(action: {
                                viewModel.sendCard(text: card)
                            }) {
                                Text(card)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
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
                        TextField("Текст карточки", text: $newCardText)
                        
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
                    },
                    trailing: Button("Добавить") {
                        viewModel.addCustomCard(category: newCardCategory, text: newCardText)
                        newCardText = ""
                        showNewCardSheet = false
                    }
                    .disabled(newCardText.isEmpty || newCardCategory.isEmpty)
                )
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.senderId == User.currentUser?.id {
                Spacer()
            }
            
            Text(message.text)
                .padding()
                .background(message.senderId == User.currentUser?.id ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.senderId == User.currentUser?.id ? .white : .primary)
                .cornerRadius(15)
            
            if message.senderId != User.currentUser?.id {
                Spacer()
            }
        }
    }
}

#Preview {
    NavigationView {
        ChatView(viewModel: ChatViewModel(chat: Chat(participants: [])))
    }
} 