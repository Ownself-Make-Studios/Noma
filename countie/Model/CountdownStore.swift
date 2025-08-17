//
//  CountdownStore.swift
//  countie
//
//  Created by Nabil Ridhwan on 17/8/25.
//

internal import Combine
import SwiftData
import SwiftUI

class CountdownStore: ObservableObject {
    @Published var countdowns: [CountdownItem] = []
    @Published var upcomingCountdowns: [CountdownItem] = []
    @Published var passedCountdowns: [CountdownItem] = []

    private var context: ModelContext

    init(context: ModelContext) {
        self.context = context
        fetchCountdowns()
    }

    func fetchCountdowns() {
        print("Fetching countdowns...")
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate { item in
                item.isDeleted == false
            },
            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )

        let fetchedItems = try? context.fetch(descriptor)

        countdowns = fetchedItems ?? []
        upcomingCountdowns = countdowns.filter { $0.date >= Date() }
        passedCountdowns = countdowns.filter { $0.date < Date() }
    }
    
    func deleteCountdown(_ countdown: CountdownItem) {
        countdown.isDeleted = true
        fetchCountdowns()
    }
        

}
