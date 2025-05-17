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
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear{
                    WidgetCenter.shared.reloadTimelines(ofKind: "CountdownWidget", )
                }
            
        }
        .modelContainer(CountieModelContainer.sharedModelContainer)
    }
}
