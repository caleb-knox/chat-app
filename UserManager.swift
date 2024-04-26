import Foundation
import FirebaseFirestore

class UserManager: ObservableObject {
    @Published var foundUser: User?
    private let db = Firestore.firestore()
    
    // Finds a user for the search bar (excluding oneself)
    func searchUserByUsername(username: String) {
        DispatchQueue.global(qos: .background).async {
            self.db.collection("users").whereField("username", isEqualTo: username)
                .getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                        self.foundUser = nil
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            DispatchQueue.main.async {
                                if let username = data["username"] as? String, let email = data["email"] as? String {
                                    self.foundUser = User(id: document.documentID, username: username, email: email)
                                    return
                                }
                            }
                            
                        }
                    }
                }
        }
    }
}

