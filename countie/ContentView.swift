//
//  ContentView.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CountdownItem.date, order: .reverse) private var items: [CountdownItem] = []
    
    @State private var showAddModal = false
    
    var body: some View {
        NavigationSplitView {
            //            HStack{
            //                Image("CountieLogo")
            //                    .resizable()
            //                    .frame(width: 50, height: 50)
            //
            //                Text("Countie")
            //                    .font(.largeTitle)
            //                    .bold()
            //            }
            
            //            Text("Hello ") + Text("Nabil, ").bold() + Text("you have \(items.count) items today. Let's get started!")
            //
            if items.isEmpty {
                
                ContentUnavailableView(
                    "No Countdowns Yet :(",
                    systemImage: "calendar",
                    description: Text("Add a countdown by tapping the plus button!"))
            }
            
            
            List {
                
                
                ForEach(items) { item in
                    NavigationLink {
                        Text("Hello there!")
                    } label: {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }.navigationTitle("Countie")
            
        } detail: {
            Text("Select an item")
        }
        .navigationTitle("Countie")
        .sheet(isPresented: $showAddModal) {
            AddCountdownView()
        }
    }
    
    private func addItem() {
        withAnimation {
            showAddModal = true
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(CountieModelContainer.sharedModelContainer)
    //        .modelContainer(for: CountdownItem.self, inMemory: false)
}
