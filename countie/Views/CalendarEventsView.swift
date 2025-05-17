//
//  CalendarEventsView.swift
//  countie
//
//  Created by Nabil Ridhwan on 2/11/24.
//

import SwiftUI
import EventKit

struct CalendarEventsView: View {
    
    var events: [EKEvent]
    var calendars: [EKCalendar]
    var onSelectEvent: ((EKEvent) -> Void)?
    
    var body: some View {
        if events.isEmpty {
            ContentUnavailableView {
                Label("No Calendar Events", systemImage: "calendar")
            } description: {
                Text("There are no calendar events available. Please check your calendar settings.")
            }
        } else {
            List(events, id: \.eventIdentifier) { event in
                NavigationLink {
                    AddCountdownView(
                        name: event.title,
                        date: event.startDate,
                        hasTime: !event.isAllDay
                    )
                } label: {
                    HStack{
                        
                        // Calendar color
                        Circle()
                            .fill(Color(event.calendar.cgColor))
                            .frame(width: 10, height: 10)
                        
                        VStack(alignment: .leading){
                            Text(event.title)
                                .font(.headline)
                            
                            Text(event.startDate.formatted())
                                .font(.subheadline)
                        }
                    }
                    
                }
                
                
                
                
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        print("Select calendar")
                    }) {
                        Text("Calendars")
                    }
                }
            }
            
            
            
        }
    }
}

#Preview {
    CalendarEventsView(events: [], calendars: [])
}
