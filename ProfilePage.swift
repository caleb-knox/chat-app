import SwiftUI
import FirebaseStorage

struct ProfilePage: View {
    @ObservedObject var loginManager: LoginManager
    @ObservedObject var messagesManager: MessagesManager
    @State private var showImagePicker = false
    @State private var profileImage: UIImage? = nil
    @State private var imageURL: URL? = nil
    @State private var totalMessagesSent: Int = 0
    @State private var totalMessagesReceived: Int = 0
    var body: some View {
        
        // Displays the UI of the profile page
        VStack(spacing: 25) {
            
            // Header
            Text("Profile")
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
            
            
            // Allows the user to click a button on the profile image and upload a new one/replace the old one
            Button(action: {
                self.showImagePicker = true
            }) {
                
                // Creates a UI image
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 150, height: 150)
                }
            }
            // Shows the apple image selector
            .sheet(isPresented: $showImagePicker, onDismiss: uploadImage) {
                ImagePicker(image: self.$profileImage)
            }
            
            
            // Displays the user information
            VStack(spacing: 15) {
                Text(loginManager.currentUser?.username ?? "")
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                Text(loginManager.currentUser?.email ?? "")
                    .font(.system(size: 17, weight: .light, design: .monospaced))
            }
            Rectangle()
                .frame(width: .infinity, height: 2)
                .foregroundColor(.brown.opacity(0.4))
                .padding(.horizontal, 20)
            
            // Stats about texting
            VStack(spacing: 15) {
                Text("Total texts received")
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                Text("\(totalMessagesReceived)")
                    .font(.system(size: 17, weight: .light, design: .monospaced))
                
            }
            
            VStack(spacing: 15) {
                Text("Total texts sent")
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                Text("\(totalMessagesSent)")
                    .font(.system(size: 17, weight: .light, design: .monospaced))
                
            }
            
            Rectangle()
                .frame(width: .infinity, height: 2)
                .foregroundColor(.brown.opacity(0.4))
                .padding(.horizontal, 20)
            
            // Resets the singleton pattern (all handled in the login manager)
            Button(action: {
                loginManager.logout()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.white)
                        .frame(width: .infinity, height: 30)
                        .padding(.horizontal, 50)
                        .shadow(radius: 2)
                    Text("Logout")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .frame(alignment: .center)
                }
            }
        }.padding(.vertical).onAppear {
            // Get the data for the user
            downloadImage()
            fetchMessageCounts()
        }
        
    }
    
    private func fetchMessageCounts() {
        guard let currentUserId = loginManager.currentUser?.id else {
            print("Error: User ID is not available")
            return
        }
        
        messagesManager.fetchMessageCount(currentUserId: currentUserId) { counts in
            if counts.count == 2 {
                self.totalMessagesSent = counts[0]
                self.totalMessagesReceived = counts[1]
            } else {
                print("Error: Unexpected counts data")
            }
        }
    }
    
    private func uploadImage() {
        guard let imageData = profileImage?.jpegData(compressionQuality: 0.4) else { return }
        let storageRef = Storage.storage().reference(withPath: "profileImages/\(loginManager.currentUser?.id ?? "unknown_user").jpg")
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                
                if let url = url {
                    print("Download URL: \(url)")
                    self.imageURL = url
                }
            }
        }
    }
    
    // Downloads the image and allows for large file sizes (then refactors it for the circle at the top of the page)
    private func downloadImage() {
        let storageRef = Storage.storage().reference(withPath: "profileImages/\(loginManager.currentUser?.id ?? "unknown_user").jpg")
        storageRef.getData(maxSize: 2 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else {
                if let data = data {
                    DispatchQueue.main.async {
                        self.profileImage = UIImage(data: data)
                        print(data)
                    }
                }
            }
        }
    }
}

// Implements an image picker using old school Swift
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
    ProfilePage(loginManager: LoginManager(), messagesManager: MessagesManager())
}
