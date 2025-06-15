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
    
    var filteredCountdowns: [CountdownItem] {
        if searchText.isEmpty {
            return countdowns
        } else {
            return countdowns.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredCountdowns, id: \.id) { countdown in
                CountdownListItemView(item: countdown)
            }
            .onDelete(perform: onDelete)
        }
        .searchable(text: $searchText, prompt: "Search countdowns")
    }
}

#Preview {
    CountdownListView(
        countdowns: [
            CountdownItem.SamplePastTimer,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
        ]
    )
}
