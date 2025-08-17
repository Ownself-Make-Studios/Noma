//
//  countieApp.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import SwiftData
import WidgetKit

@main
struct countieApp: App {
    
    
    @StateObject private var store: CountdownStore
    
    init() {
        _store = StateObject(wrappedValue: CountdownStore(context: CountieModelContainer.sharedModelContainer.mainContext))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear{
                    store.fetchCountdowns()
                }
        }
        .modelContainer(CountieModelContainer.sharedModelContainer)
    }
}
