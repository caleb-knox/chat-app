import Foundation

struct User {
    var id: String
    var username: String
    var email: String
}

struct FetchedUser {
    var id: String
    var username: String
    var email: String
    var lastSent: Date
}
