//
//  ContentView.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import SwiftData
import WidgetKit
import EventKit
import EventKitUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var items: [CountdownItem] = []
    @State private var showAddModal = false
    @State private var showCalendarModal = false
    @State private var searchText = ""
    
    private var eventViewController = EKEventViewController()
    
    @State private var events: [EKEvent] = []
    @State private var calendars: [EKCalendar] = []
    
    @AppStorage("filterPast") private var filterPast = false
    
    private func handleFilterClick(){
        filterPast.toggle()
    }
    
    private func addItem() {
        showAddModal = true
    }
    
    private func deleteItems(offsets: IndexSet) {
        
        for index in offsets {
            modelContext.delete(items[index])
        }
        
        print("Deleted item")
        try? modelContext.save()
        
        WidgetCenter.shared.reloadTimelines(ofKind: "CountdownWidget", )
    }
    
    private func fetchItems(){
        
        let now = Date.now
        
        var descriptor = FetchDescriptor<CountdownItem>(
            
            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )
        
        if filterPast {
            descriptor.predicate = #Predicate<CountdownItem> {
                $0.date >= now
            }
        }
        
        let fetchedItems = try? modelContext.fetch(descriptor)
        
        items = fetchedItems ?? []
    }
    
    var body: some View {
        NavigationStack {
            if items.isEmpty {
                ContentUnavailableView(
                    "No Countdowns Yet :(",
                    systemImage: "calendar",
                    description: Text("Add a countdown by tapping the plus button!"))
            }
            
            List {
                ForEach(items) { item in
                    NavigationLink(
                        destination: EditCountdownView(countdownItem: item)
                    )
                    {
                        CountdownListItemView(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: handleFilterClick) {
                        Label("Filter", systemImage: filterPast ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem {
                    Menu {
                        Button(action: {
                            showCalendarModal = true
                        }) {
                            Label("Add from calendar", systemImage: "calendar.badge.plus")
                        }
                        
                        Button{
                            showAddModal = true
                        } label: {
                            Label("Add new countdown", systemImage: "plus")
                        }
                        
                    } label: {
                        Button{} label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
            }
            .navigationTitle("Countie")
            //            .searchable(text: $searchText)
            
        }
        .navigationTitle("Countie")
        .sheet(isPresented: $showAddModal) {
            AddCountdownView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showCalendarModal = false
                        }
                    }
                    
                }
        }
        .sheet(isPresented: $showCalendarModal) {
            NavigationView{
                CalendarEventsView(
                    events: events,
                    calendars: calendars,
                    onSelectEvent: {
                        print($0.title ?? "Can't get event name")
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showCalendarModal = false
                        }
                    }
                    
                }
            }
            .navigationTitle("Add from Calendar")
        }
        .onChange(of: filterPast) { _, _ in
            withAnimation{
                fetchItems()
            }
        }
        .task{
            fetchItems()
            CalendarStore.requestPermission()
            
            calendars = CalendarStore.store.calendars(for: .event)
            
            let predicate = CalendarStore.store.predicateForEvents(withStart: Date.now, end: Date.distantFuture, calendars: nil)
            
            let events = CalendarStore.store.events(matching: predicate)
            
            self.events = events
        }
    }
    
    
}

#Preview {
    ContentView()
        .modelContainer(CountieModelContainer.sharedModelContainer)
    //        .modelContainer(for: CountdownItem.self, inMemory: false)
}
