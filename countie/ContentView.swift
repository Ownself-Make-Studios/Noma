//
//  ContentView.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var countdowns: [CountdownItem] = []
    @State private var showAddModal = false
    @State private var showCalendarModal = false
    @State private var searchText = ""
    
    @AppStorage("filterPast") private var filterPast = false
    
    private func handleFilterClick(){
        filterPast.toggle()
    }
    
    private func deleteItems(offsets: IndexSet) {
        
        for index in offsets {
            modelContext.delete(countdowns[index])
        }
        
        
        try? modelContext.save()
        
        // Filter from countdowns
        fetchCountdowns()
        
        print("Deleted item")

        // Ensure widget updates after deletion
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func fetchCountdowns(){
        
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
        
        countdowns = fetchedItems ?? []
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                if countdowns.isEmpty {
                    Spacer(minLength: 0)
                    ContentUnavailableView(
                        "No Countdowns Yet :(",
                        systemImage: "calendar",
                        description: Text("Add a countdown by tapping the plus button!"))
                    Spacer(minLength: 0)
                } else {
                    CountdownListView(
                        countdowns: countdowns,
                        onDelete: deleteItems
                    )
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: handleFilterClick) {
                        Label("Filter", systemImage: filterPast ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            showCalendarModal = true
                        }) {
                            Label("Add from calendar", systemImage: "calendar.badge.plus")
                        }
                        
                        Button(action: {
                            showAddModal = true
                        }) {
                            Label("Custom", systemImage: "plus")
                                .labelStyle(.titleAndIcon)
                        }
                        
                    } label: {
                        Label("Add Countdown", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }
                }
                
            }
            .navigationTitle("Countie")
        }
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
                    onSelectEvent: { _ in
                        showAddModal = false
                        showCalendarModal = false
                        fetchCountdowns()
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
                fetchCountdowns()
            }
        }
        .onChange(of: showAddModal) { oldValue, newValue in
            if oldValue != newValue && newValue == false {
                // AddCountdownView was dismissed
                fetchCountdowns()
            }
        }
        .task{
            fetchCountdowns()
        }
    }
    
    
}

#Preview {
    ContentView()
        .modelContainer(CountieModelContainer.sharedModelContainer)
    //        .modelContainer(for: CountdownItem.self, inMemory: false)
}
