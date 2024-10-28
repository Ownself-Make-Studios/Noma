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
    @Query() private var items: [CountdownItem] = []
    @State private var showAddModal = false
    @State private var searchText = ""
    
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
                        VStack(alignment:.leading){
                            Text(item.name)
                            Text(item.formattedDateString)
                                .font(.caption)
                            Text("\(item.timeRemainingString)")
                                .font(.caption2)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
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
}

#Preview {
    ContentView()
        .modelContainer(CountieModelContainer.sharedModelContainer)
    //        .modelContainer(for: CountdownItem.self, inMemory: false)
}
