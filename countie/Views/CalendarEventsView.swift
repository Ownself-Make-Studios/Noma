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
    
    @State private var selectedCalendarID: String? = nil
    @State private var searchText: String = ""
    
    var filteredEvents: [EKEvent] {
        events.filter { event in
            (selectedCalendarID == nil || event.calendar.calendarIdentifier == selectedCalendarID) &&
            (searchText.isEmpty || event.title.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Event list
            if filteredEvents.isEmpty {
                ContentUnavailableView {
                    Label("No Calendar Events", systemImage: "calendar")
                } description: {
                    Text("There are no calendar events available. Please check your calendar settings.")
                }
            } else {
                List(filteredEvents, id: \.eventIdentifier) { event in
                    NavigationLink(isActive: .constant(false)) {
                        AddCountdownView(
                            name: event.title,
                            date: event.startDate,
                            hasTime: !event.isAllDay,
                            onAdd: {
                                onSelectEvent?(event)
                            }
                        )
                    } label: {
                        HStack{
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
                .listStyle(.plain)
            }
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Picker("Calendar", selection: $selectedCalendarID) {
                        Text("All").tag(String?.none)
                        ForEach(calendars, id: \.calendarIdentifier) { calendar in
                            Text(calendar.title).tag(Optional(calendar.calendarIdentifier))
                        }
                    }
                } label: {
                    Image(
                        systemName:
                            selectedCalendarID == nil
                                ? "line.3.horizontal.decrease.circle"
                                : "line.3.horizontal.decrease.circle.fill")
                }
            }
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search events")
    }
}

#Preview {
    CalendarEventsView(events: [], calendars: [])
}
