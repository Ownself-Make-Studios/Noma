//
//  CountdownListView.swift
//  countie
//
//  Created by Nabil Ridhwan on 17/5/25.
//

import SwiftUI

struct CountdownListView: View {
    var countdowns: [CountdownItem]
    @State private var searchText: String = ""
    var onDelete: ((IndexSet) -> Void)? = nil
    
    @State private var selectedCountdown: CountdownItem? = nil
    
    var filteredCountdowns: [CountdownItem] {
        if searchText.isEmpty {
            return countdowns
        } else {
            return countdowns.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                
//                Section("Pinned"){
//                    ScrollView(.horizontal, showsIndicators: false){
//                        
//                        LazyHStack{
//                            ForEach(filteredCountdowns, id: \..id) { countdown in
//                                NavigationLink(destination: AddCountdownView(countdownToEdit: countdown)) {
//                                    CountdownListItemView(item: countdown)
//                                        .frame(maxWidth: 200)
//                                    
//                                        .padding()
//                                       
//                                }
//                                .buttonStyle(.plain)
//                                 .contextMenu {
//                                            Button("Pin") {
//                                                handlePin(countdown.id)
//                                            }
//                                        }
//                                
//                            }
////                            .onDelete(perform: onDelete)
//                        }
//                    }
//                }
                
                
                ForEach(filteredCountdowns, id: \.id) { countdown in
                    NavigationLink(destination: AddCountdownView(countdownToEdit: countdown)) {
                        CountdownListItemView(item: countdown)
                            .padding(.vertical, 4)
                            
                    }
                    .contextMenu {
                        Button("Pin") {
                            handlePin(countdown.id)
                        }
                    }
                }
                .onDelete(perform: onDelete)
            }
            .searchable(text: $searchText, prompt: "Search countdowns")
        }
    }
    
    func handlePin(_ id: UUID) {
        // Pin or unpin logic goes here
        print(id.uuidString)
    }
}

#Preview {
    CountdownListView(
        countdowns: [
            CountdownItem.SamplePastTimer,
            CountdownItem.Graduation,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
        ]
    )
}
