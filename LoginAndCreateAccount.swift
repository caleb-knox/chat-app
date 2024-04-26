import SwiftUI

struct LoginAndCreateAccount: View {
    
    @State var isLoginPageShowing: Bool = true
    @ObservedObject var loginManager: LoginManager = LoginManager()
    @State private var flipDegrees = 0.0
    
    
    var body: some View {
        
        // Checks if any user is signed in
        if !loginManager.signedIn {
            VStack {
                
                // Switches between login and create account page
                if isLoginPageShowing {
                    LoginPage(email: "", password: "", isLoginPageShowing: $isLoginPageShowing, loginManager: loginManager)
                        .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0))
                } else {
                    CreateAccountPage(email: "", username: "", password: "", confirmPassword: "", isLoginPageShowing: $isLoginPageShowing, loginManager: loginManager)
                        .rotation3DEffect(.degrees(flipDegrees - 180), axis: (x: 0, y: 1, z: 0))
                }
            }
            .animation(.linear(duration: 0.8), value: flipDegrees)
            .onChange(of: isLoginPageShowing) { _ in
                flipDegrees += 180
            }.transition(.move(edge: .leading))
            
        } else {
            // Starts the program for a specific user
            if let currentUser = loginManager.currentUser {
                MessagingPage(loginManager: loginManager, st: 0)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}


