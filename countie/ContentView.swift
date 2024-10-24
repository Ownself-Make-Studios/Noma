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
    @Query private var items: [CountdownItem] = []
    
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
                
                VStack(spacing: 8){
                     Image("CountieLogo")
                    .resizable()
                    .frame(width: 100, height: 100)
                
                    Text("No Countdown Yet :(")
                        .bold()
                        .font(.system(size: 28))
                    Text("Add a countdown by tapping the plus button!")
                        .font(.subheadline)
                }.padding()
            }
            
            
            List {
                ForEach(items) { item in
                    VStack(alignment:.leading){
                        Text(item.name)
                        Text("\(item.daysLeft)")
                            .font(.caption)
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
        .modelContainer(for: CountdownItem.self)
}
