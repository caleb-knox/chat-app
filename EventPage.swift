import SwiftUI

struct EventPage: View {
    @State var isCreateEventSheetShowing: Bool = false
    @State var eventTitle: String = ""
    @State var eventDescription: String = ""
    @State var eventTime: Date = Date()
    @State private var isRotated = false
    @ObservedObject var loginManager: LoginManager
    @ObservedObject var eventsManager = EventsManager()
    @State var selectedTop = 1
    @State var eventToSend: Event
    @State var events: [Event] = []
    @State var allEvents: [Event] = []
    @State var fUsers: [FetchedUser]
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedTop = 1
                }) {
                    if selectedTop != 1 {
                        Text("Friends events")
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundColor(.black)
                    } else {
                        Text("Friends events")
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundColor(.black).underline()
                    }
                    
                }
                Spacer()
                Button(action: {
                    selectedTop = 2
                    fetchEvents()
                }) {
                    if selectedTop == 1 {
                        Text("My events")
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundColor(.black)
                    } else {
                        Text("My events")
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundColor(.black).underline()
                    }
                }
                
            }.padding(.horizontal, 50).padding(.top)
            if selectedTop == 1 {
                ScrollView {
                    ForEach(allEvents, id: \.id) { ev in
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .padding(20)
                                .shadow(radius: 2)
                                .foregroundColor(.white)
                                .frame(height: 200)
                            VStack(alignment: .leading, spacing: 25) {
                                Text(ev.title)
                                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                                Text(ev.description)
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                
                                Text("Event is at \(ev.eventTime, formatter: DateFormatter.time) at \(ev.eventTime, formatter: DateFormatter.t)")
                                    .font(.system(size: 14, weight: .light, design: .monospaced))
                                    .foregroundColor(.brown)
                                
                                
                            }.padding(.horizontal, 25)
                        }
                    }
                }
            } else {
                ScrollView {
                    ForEach(events, id: \.id) { ev in
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .padding(20)
                                .shadow(radius: 2)
                                .foregroundColor(.white)
                                .frame(height: 200)
                            VStack(alignment: .leading, spacing: 25) {
                                Text(ev.title)
                                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                                Text(ev.description)
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                HStack(spacing: 30) {
                                    Text("Event is at \(ev.eventTime, formatter: DateFormatter.time) at \(ev.eventTime, formatter: DateFormatter.t)")
                                        .font(.system(size: 14, weight: .light, design: .monospaced))
                                        .foregroundColor(.brown)
                                    Button(action: {
                                        if let currId = loginManager.currentUser?.id {
                                            eventsManager.removeEvent(eventId: ev.id, sendUser: currId)
                                        }
                                        fetchEvents()
                                        
                                    }) {
                                        Text("Remove")
                                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                                            .underline()
                                            .foregroundColor(.red)
                                    }
                                }
                            }.padding(.horizontal, 25)
                        }
                    }
                }
            }
            Button(action: {
                isCreateEventSheetShowing.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300, height: 60)
                        .foregroundColor(.black.opacity(0.4))
                        .shadow(radius: 4)
                    HStack(spacing: 10) {
                        Text("Post an event")
                            .font(.system(size: 25, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                        
                    }
                }.offset(y: 50)
            }.sheet(isPresented: $isCreateEventSheetShowing, onDismiss: nil) {
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            isCreateEventSheetShowing.toggle()
                            isRotated = false
                        }) {
                            Text("Back to events")
                                .font(.system(size: 20, weight: .light, design: .monospaced))
                                .underline()
                                .foregroundColor(.black)
                                .padding(20)
                        }
                        Spacer()
                    }
                    
                    VStack(spacing: 30) {
                        TextField("Event title...", text: $eventTitle)
                            .frame(maxWidth: 300)
                            .background(Color(.systemGray6))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                        TextField("Event description...", text: $eventDescription)
                            .frame(maxWidth: 300)
                            .background(Color(.systemGray6))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                        
                        
                        VStack {
                            Text("When will this event happen?")
                                .foregroundColor(.gray)
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            DatePicker("", selection: $eventTime, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .accentColor(.black)
                            
                            
                        }
                        Button(action: {
                            eventToSend = Event(id: UUID().uuidString, title: eventTitle, description: eventDescription, eventTime: eventTime, timeSent: Date.now)
                            if eventTitle != "" && eventDescription != "" && eventTime != nil {
                                sendEvent()
                                fetchEvents()
                            } else {
                                print("Failed to send event.")
                            }
                            isCreateEventSheetShowing.toggle()
                            isRotated = false
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 200, height: 60)
                                    .foregroundColor(.brown.opacity(0.7))
                                    .shadow(radius: 2)
                                HStack(spacing: 10) {
                                    Text("Post event")
                                        .font(.system(size: 25, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.white)
                                    
                                    
                                }
                            }
                        }
                        Image("fw")
                            .frame(width: 200, height: 100)
                            .rotationEffect(.degrees(isRotated ? 7 : -7))
                            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isRotated)
                            .onAppear {
                                isRotated = true
                            }.scaleEffect(0.6).opacity(0.7).offset(y: 100)
                        
                    }
                    Spacer()
                }
            }
        }.onAppear {
            fetchAllEvents()
        }
    }
    
    // Gets all the events for the current user (that the user has posted themselves
    private func fetchEvents() {
        guard let currentUserId = loginManager.currentUser?.id else {
            print("Current user ID not found")
            return
        }
        
        // Orders the events
        eventsManager.fetchEvents(currentUserId: currentUserId) { fetchedEvents in
            DispatchQueue.main.async {
                self.events = fetchedEvents.sorted(by: { $0.eventTime > $1.eventTime })
            }
        }
    }
    
    
    // Fetches the events for every user in the user's messaging area (except for themselves)
    private func fetchAllEvents() {
        guard let currentUserId = loginManager.currentUser?.id else {
            print("Current user ID not found")
            return
        }
        
        // Orders the events
        eventsManager.fetchAllEvents(currentUserId: currentUserId, users: fUsers) { fetchedEvents in
            DispatchQueue.main.async {
                self.allEvents = fetchedEvents.sorted(by: { $0.eventTime > $1.eventTime })
            }
        }
    }
    
    // Post an event
    private func sendEvent() {
        eventsManager.sendEvent(event: eventToSend, sendUser: loginManager.currentUser!)
    }
}

#Preview {
    EventPage(loginManager: LoginManager(), eventToSend: Event(id: "", title: "", description: "", eventTime: Date.now, timeSent: Date.now), fUsers: [])
}
