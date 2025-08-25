//
//  nomaApp.swift
//  noma
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import SwiftData
import WidgetKit

@main
struct nomaApp: App {
    @StateObject private var store: CountdownStore
    @State private var selectedCountdown: CountdownItem? = nil
    
    init() {
        _store = StateObject(wrappedValue: CountdownStore(context: NomaModelContainer.sharedModelContainer.mainContext))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(selectedCountdown: $selectedCountdown)
                .environmentObject(store)
                .onAppear{
                    store.fetchCountdowns()
                }
                .onOpenURL { url in
                    print("Opened with URL: \(url)")
                    print("Url scheme: \(url.scheme ?? "nil")")
                    print("Url path: \(url.path)")
                    print("Url path components: \(url.pathComponents)")
                    
                    
                    // Deep link format: noma://countdown/<UUID>
                    let pathComponents = url.pathComponents
                    if url.scheme == "noma" && pathComponents.count == 2 && pathComponents[0] == "/" {
                        let uuidString = pathComponents[1]
                        if let uuid = UUID(uuidString: uuidString) {
                            // Search for countdown in store
                            if let found = store.countdowns.first(where: { $0.id == uuid }) {
                                selectedCountdown = found
                                print("Countdown found: \(found.name)")
                            } else {
                                // Optionally handle not found
                                selectedCountdown = nil
                                print("Countdown with UUID \(uuid) not found.")
                            }
                        } else {
                            // Optionally handle invalid UUID
                            selectedCountdown = nil
                            print("Invalid UUID string: \(uuidString)")
                        }
                    }
                }
        }
        .modelContainer(NomaModelContainer.sharedModelContainer)
    }
}
