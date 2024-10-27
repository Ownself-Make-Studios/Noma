//
//  ModelContainer.swift
//  countie
//
//  Created by Nabil Ridhwan on 25/10/24.
//

import SwiftData

struct CountieModelContainer {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CountdownItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
