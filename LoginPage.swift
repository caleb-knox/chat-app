import SwiftUI

struct LoginPage: View {
    
    
    @State var email: String
    @State var password: String
    @Binding var isLoginPageShowing: Bool
    @State private var isRotated = false
    @ObservedObject var loginManager: LoginManager
    
    var body: some View {
        VStack(spacing: 30) {
            // Title
            VStack {
                Text("Glyph")
                    .font(.system(size: 40, weight: .semibold, design: .monospaced))
                    .fontWeight(.light)
                    .foregroundColor(Color.black)
                    .padding(3)
                Text("Where messaging is made easy!")
                    .font(.system(size: 16, weight: .light, design: .monospaced))
                    .foregroundColor(.gray)
            }
            
            //Background for login info
            ZStack {
                RoundedRectangle(cornerRadius: 31)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: 401, maxHeight: 401)
                    .shadow(radius: 6)
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 400, maxHeight: 400)
                
                VStack(spacing: 25) {
                    
                    Text("Login")
                        .font(.system(size: 25, weight: .semibold, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    //Email Field
                    ZStack {
                        
                        
                        TextField("Email", text: $email)
                            .frame(maxWidth: 300)
                            .background(Color(.systemGray6))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                        
                    }
                    
                    //Password Field
                    ZStack {
                        
                        SecureField("Password", text: $password)
                            .frame(maxWidth: 300)
                            .background(Color(.systemGray6))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                        
                        
                        
                    }
                    
                    // Implements the google auth for signing in
                    VStack(spacing: 25) {
                        Button(action: {
                            loginManager.signIn(email: email, password: password)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 150, height: 50)
                                    .foregroundColor(.brown.opacity(0.6))
                                    .shadow(radius: 4)
                                Text("Sign In")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .light, design: .monospaced))
                            }
                        }
                        
                        // Switch to create account view
                        Button(action: {
                            isLoginPageShowing.toggle()
                        }) {
                            HStack {
                                Text("Don't have an account yet?")
                                    .font(.system(size: 14, weight: .light, design: .monospaced))
                                    .foregroundColor(.gray)
                                
                                Text("Sign up")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.black)
                                    .underline()
                                
                            }
                        }
                    }
                    
                }
                
            }
            
            // Cool rotating image!
            Image("loginpic")
                .frame(width: 200, height: 100)
                .rotationEffect(.degrees(isRotated ? 7 : -7))
                .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isRotated)
                .onAppear {
                    isRotated = true
                }.scaleEffect(0.6).opacity(0.7)
        }
    }
}
