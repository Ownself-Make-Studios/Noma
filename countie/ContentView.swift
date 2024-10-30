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
    @State private var items: [CountdownItem] = []
    @State private var showAddModal = false
    @State private var searchText = ""
    
    @AppStorage("filterPast") private var filterPast = true
    
    private func handleFilterClick(){
        filterPast.toggle()
    }
    
    private func addItem() {
        showAddModal = true
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        }
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
                    Button(action: addItem) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Countie")
            //            .searchable(text: $searchText)
            
        }
        .navigationTitle("Countie")
        .sheet(isPresented: $showAddModal) {
            AddCountdownView()
        }
        .onChange(of: filterPast) { _, _ in
            withAnimation{
                fetchItems()
            }
        }
        .task{
            fetchItems()
        }
    }
    
    
}

#Preview {
    ContentView()
        .modelContainer(CountieModelContainer.sharedModelContainer)
    //        .modelContainer(for: CountdownItem.self, inMemory: false)
}
