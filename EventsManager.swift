import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class EventsManager: ObservableObject {
    private let db = Firestore.firestore()
    
    // Sends a new event to a specific user's events collection
    func sendEvent(event: Event, sendUser: User) {
        let documentRef = db.collection("users").document(sendUser.id).collection("events").document(event.id)
        documentRef.setData(["id": event.id, "title": event.title, "description": event.description, "eventTime": event.eventTime, "timeSent": event.timeSent]) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message successfully sent!")
            }
        }
        
        
    }
    
    // Deletes an event from a certain user's events collection
    func removeEvent(eventId: String, sendUser: String) {
        let db = Firestore.firestore()
            let documentRef = db.collection("users").document(sendUser).collection("events").document(eventId)

            documentRef.delete { error in
                if let error = error {
                    print("Error removing document: \(error.localizedDescription)")
                } else {
                    print("Document successfully removed!")
                }
            }
    }
    
    // Fetches event's for the current user
    func fetchEvents(currentUserId: String, completion: @escaping ([Event]) -> Void) {
        let evRef = db.collection("users").document(currentUserId).collection("events")
        
        evRef.order(by: "timeSent", descending: false).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
                completion([])
            } else {
                var events = [Event]()
                snapshot?.documents.forEach { document in
                    let data = document.data()
                    if let id = data["id"] as? String,
                       let title = data["title"] as? String,
                       let description = data["description"] as? String,
                       let eventTime = data["eventTime"] as? Timestamp,
                       let timeSent = data["timeSent"] as? Timestamp {
                        let event = Event(id: id, title: title, description: description, eventTime: eventTime.dateValue(), timeSent: timeSent.dateValue())
                        events.append(event)
                    }
                }
                completion(events)
            }
        }
    }
    
    // Fetches events of all people the user has messaged, not itself
    func fetchAllEvents(currentUserId: String, users: [FetchedUser], completion: @escaping ([Event]) -> Void) {
        let db = Firestore.firestore()
        var allEvents = [Event]()
        let group = DispatchGroup()

        for user in users {
            if user.id == currentUserId {
                continue
            }
            group.enter()
            let evRef = db.collection("users").document(user.id).collection("events")

            evRef.order(by: "timeSent", descending: false).getDocuments { (snapshot, error) in
                defer { group.leave() }
                if let error = error {
                    print("Error fetching events for user \(user.username): \(error.localizedDescription)")
                } else {
                    snapshot?.documents.forEach { document in
                        let data = document.data()
                        if let id = data["id"] as? String,
                           let title = data["title"] as? String,
                           let description = data["description"] as? String,
                           let eventTime = data["eventTime"] as? Timestamp,
                           let timeSent = data["timeSent"] as? Timestamp {
                            let event = Event(id: id, title: title, description: description, eventTime: eventTime.dateValue(), timeSent: timeSent.dateValue())
                            allEvents.append(event)
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(allEvents)
        }
    }
}
