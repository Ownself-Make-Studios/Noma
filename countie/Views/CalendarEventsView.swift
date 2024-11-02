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
        List(events, id: \.eventIdentifier) { event in
            NavigationLink {
                event.isAllDay ? AddCountdownView(
                    name: event.title,
                    
                    date: event.startDate,
                    hasTime: false
                ) :
                AddCountdownView(
                    name: event.title,
                    date: event.startDate,
                    hasTime: true
                    
                )
            } label: {
                HStack{
                    Rectangle()
                        .fill(Color(event.calendar.cgColor))
                        .frame(width: 10, height: 10)
                        .cornerRadius(5)
                    
                    VStack(alignment: .leading){
                        Text(event.title)
                            .font(.headline)
                        
                        Text(event.startDate.formatted())
                            .font(.subheadline)
                    }
                }
                
            }
            
        }
        
        
    }
}

#Preview {
    CalendarEventsView(events: [], calendars: [])
}
