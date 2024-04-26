import Foundation
import FirebaseAuth
import FirebaseFirestore

class LoginManager: ObservableObject {
    
    let auth = Auth.auth()
    let db = Firestore.firestore()
    
    @Published var signedIn = false
    @Published var currentUser: User?

    // Sign in with google auth, update current user
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self, let user = result?.user, error == nil else {
                print("Sign in failed:", error?.localizedDescription ?? "No error")
                return
            }
            self.signedIn = true
            self.fetchUserFromFirestore(userId: user.uid)
        }
    }
    
    // Sign up with google auth, update current user
    func signUp(email: String, username: String, password: String) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self, let user = result?.user, error == nil else {
                print("Sign up failed:", error?.localizedDescription ?? "No error")
                return
            }
            let userData = [
                "id": user.uid,
                "username": username,
                "email": email
            ]
            self.db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Error writing document:", error.localizedDescription)
                } else {
                    self.signedIn = true
                    self.currentUser = User(id: user.uid, username: username, email: email)
                }
            }
        }
    }

    // Finds the current user
    func fetchUserFromFirestore(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self, let document = document, document.exists, let data = document.data() else {
                print("No user found:", error?.localizedDescription ?? "No error")
                return
            }
            if let username = data["username"] as? String, let email = data["email"] as? String {
                self.currentUser = User(id: userId, username: username, email: email)
            }
        }
    }
    
    // Reset
    func logout() {
        do {
            try auth.signOut()
            signedIn = false
            currentUser = nil
        } catch {
            print("Error signing out:", error.localizedDescription)
        }
    }
}
