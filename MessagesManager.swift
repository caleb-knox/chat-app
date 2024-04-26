import FirebaseFirestore

class MessagesManager: ObservableObject {
    private let db = Firestore.firestore()
    
    // Send a message
    func sendMessage(message: Message, sendUser: User, receiveUser: User) {
        let documentRef = db.collection("users").document(sendUser.id).collection("messagers").document(receiveUser.id).collection("messages").document(message.id)
        documentRef.setData(["id": message.id, "text": message.text, "received": false, "timeSent": message.timeSent]) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message successfully sent!")
            }
        }
        
        // Create a user
        let userData = [
            "id": receiveUser.id,
            "username": receiveUser.username,
            "email": receiveUser.email,
            "lastSent": message.timeSent
        ] as [String : Any]
        
        // Set the data in the sending user's messsages
        db.collection("users").document(sendUser.id).collection("messagers").document(receiveUser.id).setData(userData)
        
        let documentRefTwo = db.collection("users").document(receiveUser.id).collection("messagers").document(sendUser.id).collection("messages").document(message.id)
        documentRefTwo.setData(["id": message.id, "text": message.text, "received": true, "timeSent": message.timeSent]) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message successfully sent!")
            }
        }
        
        // Create second user
        let userDataTwo = [
            "id": sendUser.id,
            "username": sendUser.username,
            "email": sendUser.email,
            "lastSent": message.timeSent
        ] as [String : Any]
        
        // Set the data in the receiving user's messsages
        db.collection("users").document(receiveUser.id).collection("messagers").document(sendUser.id).setData(userDataTwo)
    }
    
    // Function to fetch messages between two specific users
    func fetchMessages(currentUserId: String, otherUserId: String, completion: @escaping ([Message]) -> Void) {
        let messagesRef = db.collection("users").document(currentUserId).collection("messagers").document(otherUserId).collection("messages")
        
        messagesRef.order(by: "timeSent", descending: false).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                completion([])
            } else {
                // Create messages based on field data and store it in a list
                var messages = [Message]()
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let id = data["id"] as? String,
                       let text = data["text"] as? String,
                       let timeSent = data["timeSent"] as? Timestamp,
                       let received = data["received"] as? Bool {
                        let message = Message(id: id, text: text, received: received, timeSent: timeSent.dateValue())
                        messages.append(message)
                    }
                }
                completion(messages)
            }
        }
    }
    
    func fetchMessagers(currentUserId: String, completion: @escaping ([FetchedUser]) -> Void) {
        let messagersRef = db.collection("users").document(currentUserId).collection("messagers")

        messagersRef.order(by: "lastSent", descending: false).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching messagers: \(error.localizedDescription)")
                completion([])
                return
            }
            var users = [FetchedUser]()
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    print("Fetched messager data: \(data)")
                    if let id = data["id"] as? String,
                       let username = data["username"] as? String,
                       let email = data["email"] as? String,
                       let lastSentTimestamp = data["lastSent"] as? Timestamp {
                        let user = FetchedUser(id: id, username: username, email: email, lastSent: lastSentTimestamp.dateValue())
                        users.append(user)
                    }
                }
            }
            completion(users)
        }
    }
    
    func fetchMessageCount(currentUserId: String, completion: @escaping ([Int]) -> Void) {
        let messagersRef = db.collection("users").document(currentUserId).collection("messagers")
        var totalSent = 0
        var totalReceived = 0

        messagersRef.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching messagers: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            let group = DispatchGroup()

            for document in documents {
                let messagerId = document.documentID
                let messagesRef = self.db.collection("users").document(currentUserId).collection("messagers").document(messagerId).collection("messages")
                
                group.enter()
                messagesRef.getDocuments { (messageSnapshot, messageError) in
                    guard let messageDocuments = messageSnapshot?.documents, messageError == nil else {
                        print("Error fetching messages for messager \(messagerId): \(messageError?.localizedDescription ?? "Unknown error")")
                        group.leave()
                        return
                    }

                    for messageDocument in messageDocuments {
                        let messageData = messageDocument.data()
                        if let received = messageData["received"] as? Bool {
                            if received {
                                totalReceived += 1
                            } else {
                                totalSent += 1
                            }
                        }
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion([totalSent, totalReceived])
            }
        }
    }
}
