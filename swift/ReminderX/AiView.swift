import SwiftUI
import Foundation
import ChatGPTSwift

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct AiView: View {
    @State private var userMessage = ""
    @State private var messages: [ChatMessage] = []
    @State private var isWaitingForResponse = false
    @State private var showMiniCards = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var navbarVisible: Bool = true
    @ObservedObject var viewModel: ReminderXViewModel
    @State private var isTyping = false
    @State private var typingMessage = ""
    @State private var aiTypingMessage = ""
    @State private var lastSentMessageDate = Date(timeIntervalSince1970: 0)
    @State private var typingMessages: [(UUID, String)] = []
    @State private var gradientRotation: Double = 0
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    let gradientColors = [ColorSchemeManager.shared.currentColorScheme.med, ColorSchemeManager.shared.currentColorScheme.light]
    let api = ChatGPTAPI(apiKey: "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")
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            AngularGradient(
                                gradient: Gradient(colors: gradientColors),
                                center: .center,
                                startAngle: .degrees(gradientRotation),
                                endAngle: .degrees(gradientRotation + 360)
                            )
                        )
                        .blur(radius: 70)
                        .edgesIgnoringSafeArea(.vertical)
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: -5, y: -5)
                        .shadow(color: .gray.opacity(0.2), radius: 10, x: 5, y: 5)
                        .padding(.horizontal)
                    
                    VStack {
                        if !navbarVisible { Spacer(minLength: 10) }
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack {
                                    ForEach(messages) { message in
                                        chatMessageView(message: message)
                                    }
                                    ForEach(typingMessages, id: \.0) { message in
                                        typingMessageView(typingMessage: message.1)
                                    }
                                }
                                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        
                        Spacer()
                        
                        VStack {
                            HStack {
                                TextField("Ask Anything", text: $userMessage)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.07))
                                    .cornerRadius(15)
                                Button(action: sendMessage) {
                                    Image(systemName: "paperplane")
                                        .foregroundColor(.gray)
                                        .padding(10)
                                        .frame(width: 30, height: 30)
                                }
                                .foregroundColor(.gray)
                                .disabled(!isSendButtonEnabled())
                            }
                            .padding(.horizontal)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .padding(.bottom, 76)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startListeningForKeyboardNotifications()
                loadMessages() // Add this line
                if messages.isEmpty {
                }
                withAnimation(Animation.linear(duration: 8).repeatForever(autoreverses: false)) {
                    gradientRotation = 360
                }
            }
        }
    }
        
        private func isSendButtonEnabled() -> Bool {
            let isInputNotEmpty = !userMessage.trimmingCharacters(in: .whitespaces).isEmpty
            let timeSinceLastMessage = Date().timeIntervalSince(lastSentMessageDate)
            let minTimeBetweenMessages: TimeInterval = 3
            return isInputNotEmpty && !isWaitingForResponse && timeSinceLastMessage >= minTimeBetweenMessages
        }
        
        
        private func sendMessage() {
            let message = ChatMessage(text: userMessage, isUser: true)
            messages.append(message)
            saveMessages()
            userMessage = ""
            lastSentMessageDate = Date()
            
            isWaitingForResponse = true
            fetchChatGPTResponse(viewModel: viewModel, prompt: message.text) { result in
                switch result {
                case .success(let (messageID, aiMessageText)):
                    DispatchQueue.main.async {
                        self.typingMessages.append((messageID, aiMessageText))
                        Task {
                            await Task.sleep(UInt64(0.05 * Double(aiMessageText.count) * 1_000_000))
                            messages.append(ChatMessage(text: aiMessageText, isUser: false))
                            typingMessages.removeAll { $0.0 == messageID }
                            isWaitingForResponse = false
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        private func fetchChatGPTResponse(viewModel: ReminderXViewModel, prompt: String, completion: @escaping (Result<(UUID, String), Error>) -> Void) {
            let reminders = viewModel.folders.flatMap { $0.reminders }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let currentTime = dateFormatter.string(from: Date())
            let chat = """
            Act as NodeAI, a calendar assistant specializing conversating effectivly about user tasks. These are the users reminders so STRICTLY refer only to these in your response, it might be empty. \(reminders) when responding. If no reminders are available, do not create or imagine any, as the user may simply have none at the moment. Ensure proper capitalization and use natural language when communicating. Format dates and times as they would be spoken or written in everyday conversation, rather than replicating the format from the list. Keep in mind the current date: \(currentTime). user's prompt here: \(prompt).
            """
            Task {
                do {
                    let stream = try await api.sendMessageStream(text: chat)
                    var aiMessageText = ""
                    let messageID = UUID()
                    for try await line in stream {
                        DispatchQueue.main.async {
                            aiMessageText += line
                            if let index = typingMessages.firstIndex(where: { $0.0 == messageID }) {
                                typingMessages[index] = (messageID, aiMessageText)
                            } else {
                                typingMessages.append((messageID, aiMessageText))
                            }
                        }
                    }
                    
                    // Second prompt for suggestions
                    let suggestionsPrompt = """
                    make me a table of prompts i would likely do next as a user to a calender assistant in this format "Replace with prediction 1 : replace with prediction 2 : replace with prediction 3" and output no other text in your response
                    """
                    let suggestionsStream = try await api.sendMessageStream(text: suggestionsPrompt)
                    var suggestionsText = ""
                    for try await line in suggestionsStream {
                        DispatchQueue.main.async {
                            suggestionsText += line
                        }
                    }
                    let responseArray = suggestionsText.split(separator: ":")
                    for suggestion in responseArray {
                        let trimmedSuggestion = suggestion.trimmingCharacters(in: .whitespacesAndNewlines)
                        print(trimmedSuggestion)
                    }
                    
                    
                    let result = Result<(UUID, String), Error>.success((messageID, aiMessageText))
                    handleResult(result)
                }
            }
            
            func handleResult(_ result: Result<(UUID, String), Error>) {
                switch result {
                case .success(let (messageID, aiMessageText)):
                    DispatchQueue.main.async {
                        messages.append(ChatMessage(text: aiMessageText, isUser: false))
                        typingMessages.removeAll { $0.0 == messageID }
                        isWaitingForResponse = false
                        saveMessages() // Add this line
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        
        
        private func chatMessageView(message: ChatMessage) -> some View {
            VStack(alignment: .leading) {
                HStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(message.isUser
                              ? LinearGradient(gradient: Gradient(colors: [.black, .black]), startPoint: .top, endPoint: .bottom)
                              : LinearGradient(gradient: Gradient(colors: [ColorSchemeManager.shared.currentColorScheme.med.opacity(0.5), ColorSchemeManager.shared.currentColorScheme.med.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 52, height: 30)
                        .overlay(
                            Text(message.isUser ? "You" : "Node")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(message.isUser ? .white : .white)
                        )
                        .shadow(color: .gray.opacity(0.6), radius: 5, x: 0, y: 5)
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(message.text)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                            .foregroundColor(message.isUser ? .black : .black)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        
        
        
        private func saveMessages() {
            let encoder = JSONEncoder()
            if let encodedMessages = try? encoder.encode(messages) {
                UserDefaults.standard.set(encodedMessages, forKey: "SavedMessages")
            }
        }
        
        private func loadMessages() {
            let decoder = JSONDecoder()
            if let savedMessagesData = UserDefaults.standard.data(forKey: "SavedMessages"),
               let decodedMessages = try? decoder.decode([ChatMessage].self, from: savedMessagesData) {
                messages = decodedMessages
            }
        }
        
        private func typingMessageView(typingMessage: String) -> some View {
            VStack(alignment: .leading) {
                HStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(LinearGradient(gradient: Gradient(colors: [ColorSchemeManager.shared.currentColorScheme.med.opacity(0.5), ColorSchemeManager.shared.currentColorScheme.med.opacity(0.3)]), startPoint: .top, endPoint: .bottom))
                        .frame(width: 52, height: 30)
                        .overlay(
                            Text("HiveAI")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                    Spacer()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(typingMessage)
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    struct AiView_Previews: PreviewProvider {
        static var previews: some View {
            AiView(viewModel: ReminderXViewModel())
        }
    }
    
    extension AiView {
        private func startListeningForKeyboardNotifications() {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                guard let userInfo = notification.userInfo else { return }
                guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                keyboardHeight = keyboardSize.height
                navbarVisible = false
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
                navbarVisible = true
            }
        }
    }
