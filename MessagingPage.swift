import SwiftUI

struct MessagingPage: View {
    @State var messageToSend: String = ""
    @State var isMessagingViewShowing: Bool = false
    @State var searchText: String = ""
    @State var messagingUser: User = User(id: "", username: "", email: "")
    @State var messages: [Message] = []
    @State var messagers: [FetchedUser] = []
    @State var messageTime: Bool = false
    @State var currentClick: Message? = nil  // Use optional for easier comparison
    @State var scrollToBottom: Bool = false
    @State var searchView: Bool = false
    @ObservedObject var userManager = UserManager()
    @ObservedObject var loginManager: LoginManager
    @ObservedObject var messagesManager = MessagesManager()
    @State var st: Int
    
    var body: some View {
        
        VStack {
            
            // Tab bar for the messagers view (seeing all the people you are currently messaging
            if st == 0 {
                
                // This is the view that changes to seeing the messaging for a specified user
                if isMessagingViewShowing {
                    VStack {
                        HStack(spacing: 0) {
                            // Go back to the messagers button
                            Button(action: {
                                isMessagingViewShowing.toggle()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(.mint)
                            }.offset(x: -90)
                            
                            // Header username
                            Text(messagingUser.username)
                                .font(.title)
                                .fontWeight(.thin)
                                .offset(x: -5)
                        }
                        
                        // This is the scroll view stack that shows the messages between you and the other user
                        VStack(spacing: 0) {
                            ScrollView {
                                ScrollViewReader { scrollViewProxy in
                                    VStack(spacing: 12) {
                                        ForEach($messages, id: \.id) { $message in
                                            HStack {
                                                
                                                // Allows you to see the date of the message
                                                Button(action: {
                                                    self.messageTime.toggle()
                                                    self.currentClick = message
                                                }) {
                                                    VStack(spacing: 0) {
                                                        Text(message.text)
                                                            .padding()
                                                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                                                            .background(message.received ? Color.gray : Color.blue)
                                                            .cornerRadius(12)
                                                            .foregroundColor(.white)
                                                            .frame(maxWidth: .infinity, alignment: message.received ? .leading : .trailing)
                                                        
                                                        if messageTime && currentClick?.id == message.id {
                                                            Text("\(message.timeSent, formatter: DateFormatter.time)")
                                                                .frame(maxWidth: .infinity, alignment: message.received ? .leading : .trailing)
                                                                .padding()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Updates the view so it always scrolls to the most recent message
                                    }.onChange(of: scrollToBottom) { _ in
                                        if scrollToBottom {
                                            if let lastMessage = messages.last {
                                                scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                                                scrollToBottom = false
                                            }
                                        }
                                    }
                                    
                                    // Auto scrolls to the bottom
                                    .onAppear {
                                        scrollToBottom = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                            ZStack {
                                
                                // This is the stack that allows you to send a message
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18)
                                        .foregroundColor(.white)
                                        .shadow(radius: 6)
                                        .padding()
                                        .frame(maxWidth: 365, maxHeight: 90)
                                    HStack {
                                        TextField("Type message here...", text: $messageToSend)
                                        
                                        // Sends and then refetches all of the messages
                                        Button(action: {
                                            if messageToSend != "" {
                                                sendMessage()
                                                fetchMessages()
                                                scrollToBottom = true
                                            }
                                        }) {
                                            Image(systemName: "paperplane.circle")
                                                .font(.system(size: 30))
                                                .foregroundColor(.gray)
                                        }
                                    }.padding(.horizontal, 50)
                                }
                            }
                        }
                        Spacer()
                    }.onAppear {
                        fetchMessages()
                    }
                    
                    // Messagers view
                } else {
                    VStack {
                        
                        // Show the user that you have searched for
                        if searchView {
                            VStack {
                                Button(action: {
                                    userManager.foundUser = nil
                                    searchText = ""
                                    searchView = false
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(width: .infinity, height: 30)
                                            .padding(.horizontal, 80)
                                            .shadow(radius: 2)
                                        Text("Go back")
                                            .foregroundColor(.black)
                                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                            .padding(.horizontal, 30)
                                            .padding(.vertical, 10)
                                            .frame(alignment: .center)
                                    }
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundColor(.white)
                                        .frame(width: .infinity, height: 80)
                                        .padding(10)
                                        .shadow(radius: 2)
                                    
                                    
                                    HStack {
                                        VStack(spacing: 0) {
                                            Text(userManager.foundUser!.username)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                                .padding(.horizontal, 30)
                                                .padding(.vertical, 10)
                                            
                                        }
                                        Button(action: {
                                            messagingUser = userManager.foundUser!
                                            userManager.foundUser = nil
                                            searchText = ""
                                            fetchMessages()
                                            isMessagingViewShowing = true
                                            searchView = false
                                        }) {
                                            
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(.brown.opacity(0.7))
                                                    .frame(width: 50)
                                                
                                                Image(systemName: "message.fill")
                                                    .foregroundColor(.white)
                                                
                                            }.padding(.horizontal, 25)
                                        }
                                    }
                                }
                            }
                            
                            
                            // Displays all current messagers and a search bar to search for new ones
                        } else {
                            
                            // When you click enter it will try and find a user with the username that you have inputted
                            TextField("Search usernames...", text: $searchText, onCommit: {
                                userManager.searchUserByUsername(username: searchText)
                                
                                    if let user = userManager.foundUser {
                                        searchView = true
                                    } else {
                                        searchText = ""
                                        userManager.foundUser = nil
                                        searchView = false
                                    }
                                
                                
                            }).autocapitalization(.none)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .padding()
                            
                            // Messagers header
                            Text("Your friends miss you... Say hi!")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            
                            // Scroll view that shows all of your current messagers
                            ScrollView {
                                ForEach(messagers, id: \.id) { user in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 25)
                                            .foregroundColor(.white)
                                            .frame(width: .infinity, height: 80)
                                            .padding(10)
                                            .shadow(radius: 2)
                                        
                                        
                                        HStack {
                                            
                                            // Displays user info and the last time you shared a message
                                            VStack(spacing: -10) {
                                                Text(user.username)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                                    .padding(.horizontal, 30)
                                                    .padding(.vertical, 10)
                                                Text("Last message on \(user.lastSent, formatter: DateFormatter.time)")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 15, weight: .light, design: .monospaced))
                                                    .padding(.horizontal, 30)
                                                    .padding(.vertical, 10)
                                                
                                            }
                                            
                                            // Switches to messaging view for a specified user on click
                                            Button(action: {
                                                messagingUser = User(id: user.id, username: user.username, email: user.email)
                                                fetchMessages()
                                                isMessagingViewShowing = true
                                                userManager.foundUser = nil
                                            }) {
                                                
                                                ZStack {
                                                    Circle()
                                                        .foregroundColor(.brown.opacity(0.7))
                                                        .frame(width: 50)
                                                    
                                                    Image(systemName: "message.fill")
                                                        .foregroundColor(.white)
                                                    
                                                }.padding(.horizontal, 25)
                                            }
                                        }
                                    }
                                    
                                }
                            }.onAppear {
                                fetchMessagers()
                            }
                        }
                        
                    }
                }
            }  else {
                
                // This is the tab bar for the events page
                if st == 1 {
                    
                    EventPage(loginManager: loginManager, eventToSend: Event(id: "", title: "", description: "", eventTime: Date.now, timeSent: Date.now), fUsers: messagers).onAppear {
                        isMessagingViewShowing = false
                    }
                    
                    // This is the tab bar for the profile page
                } else {
                    ProfilePage(loginManager: loginManager, messagesManager: messagesManager).onAppear {
                        isMessagingViewShowing = false
                    }
                }
            }
            
            // Shows the tab bar for everything *except* for the messaging view (actualling reading and sending messages)
            if !isMessagingViewShowing {
                Spacer()
                TabBar(selectedTab: $st)
            }
        }
    }
    
    // Fetches all the messages between you and another user
    private func fetchMessages() {
        guard let currentUserId = loginManager.currentUser?.id else {
            print("Current user ID not found")
            return
        }
        
        let otherUserId = messagingUser.id
        messagesManager.fetchMessages(currentUserId: currentUserId, otherUserId: otherUserId) { fetchedMessages in
            DispatchQueue.main.async {
                self.messages = fetchedMessages.sorted(by: { $0.timeSent < $1.timeSent })
            }
        }
    }
    
    
    // Fetches all users that you have sent or received a message with
    private func fetchMessagers() {
        guard let currentUserId = loginManager.currentUser?.id else {
            print("Current user ID not found")
            return
        }
        
        messagesManager.fetchMessagers(currentUserId: currentUserId) { fetchedMessagers in
            DispatchQueue.main.async {
                self.messagers = fetchedMessagers.sorted(by: { $0.lastSent > $1.lastSent })
            }
        }
    }
    
    // Sends a message to a specified user -- this will put a message in both you and your receivers account (as received false or true respectively)
    private func sendMessage() {
        let newMessage = Message(
            id: UUID().uuidString,
            text: messageToSend,
            received: false,
            timeSent: Date()
        )
        messagesManager.sendMessage(message: newMessage, sendUser: loginManager.currentUser!, receiveUser: messagingUser)
        messageToSend = ""
    }
}


// Shows the date of a timestamp
extension DateFormatter {
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter
    }()
}

// Shows the time of a timestamp
extension DateFormatter {
    static let t: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

struct TabBar: View {
    @Binding var selectedTab: Int
    @State private var scales = [CGFloat](repeating: 1.0, count: 3)
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                // Indent view
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 10)
                        .overlay(
                            Rectangle()
                                .fill(.black.opacity(0.4))
                                .frame(width: geometry.size.width / 6, height: 5)
                                .offset(x: CGFloat(self.selectedTab) * (geometry.size.width / 3) + 48 - (self.selectedTab == 1 ? 15 : (self.selectedTab == 2 ? 33 : 0)), y: 21),
                            alignment: .leading
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: selectedTab)
                }
                .frame(height: 10)
            }
            
            HStack {
                // Message Button
                Button(action: {
                    self.selectedTab = 0
                    self.animateButton(index: 0)
                }) {
                    Image(systemName: "message.fill")
                        .font(.title)
                }
                .scaleEffect(scales[0])
                .foregroundColor(.black.opacity(0.6))
                
                Spacer()
                
                // Events Button
                Button(action: {
                    self.selectedTab = 1
                    self.animateButton(index: 1)
                }) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 30))
                }
                .scaleEffect(scales[1])
                .foregroundColor(.black.opacity(0.6))
                
                Spacer()
                
                // Profile Button
                Button(action: {
                    self.selectedTab = 2
                    self.animateButton(index: 2)
                }) {
                    Image(systemName: "person.fill")
                        .font(.largeTitle)
                }
                .scaleEffect(scales[2])
                .foregroundColor(.black.opacity(0.6))
            }
            .padding(.horizontal, 65)
            .padding(.vertical, 20)
            .background(Color.brown.opacity(0.2))
            .cornerRadius(15)
        }
        .offset(y: 35)
        .padding(.top, 23)
    }
    
    // Springs the current selector rectangle across tabs on click
    private func animateButton(index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scales[index] = 0.85 // Scales down when pressed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring()) {
                    scales[index] = 1.0
                }
            }
        }
    }
}


#Preview {
    MessagingPage(messageToSend: "", isMessagingViewShowing: false, loginManager: LoginManager(), st: 0)
}



