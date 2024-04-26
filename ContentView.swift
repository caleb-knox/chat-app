import SwiftUI

struct ContentView: View {
    
    // Beginning of singleton pattern
    let loginManager = LoginManager()
    
    var body: some View {
        
        LoginAndCreateAccount(loginManager: loginManager)
        
    }
}
