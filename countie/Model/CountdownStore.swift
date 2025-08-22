//
//  CountdownStore.swift
//  countie
//
//  Created by Nabil Ridhwan on 17/8/25.
//

internal import Combine
import EventKit
import SwiftData
import SwiftUI
import WidgetKit

class CountdownStore: ObservableObject {
    private var eventStore = EKEventStore()
    private var cancellables: [NSObjectProtocol] = []

    @Published var countdowns: [CountdownItem] = []
    @Published var upcomingCountdowns: [CountdownItem] = []
    @Published var passedCountdowns: [CountdownItem] = []

    private var context: ModelContext

    init(context: ModelContext) {
        self.context = context
        fetchCountdowns()

        let token = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: self.eventStore,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }

            if let countdowns = fetchCalendarLinkedCountdowns() {
                countdowns.forEach { countdown in
                    if let event = self.eventStore.event(
                        withIdentifier: countdown.calendarEventIdentifier ?? ""
                    ) {
                        if event.startDate >= Date() {
                            countdown.date = event.startDate
                        }
                    }
                }
            }

            WidgetCenter.shared.reloadAllTimelines()
        }

        cancellables.append(token)
    }

    deinit {
        for token in cancellables {
            NotificationCenter.default.removeObserver(token)
        }
    }

    func fetchCalendarLinkedCountdowns() -> [CountdownItem]? {
        let currentDate = Date()
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> {
                $0.isDeleted == false && $0.calendarEventIdentifier != nil
                    && $0.date >= currentDate
            },
            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )

        let fetchedItems = try? context.fetch(descriptor)

        return fetchedItems
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

        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func fetchDeletedCountdowns() -> [CountdownItem]? {
        print("Fetching countdowns...")
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate { item in
                item.isDeleted == true
            },
            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )

        let fetchedItems = try? context.fetch(descriptor)
        return fetchedItems ?? []
    }

    func deleteCountdown(_ countdown: CountdownItem) {
        countdown.isDeleted = true
        fetchCountdowns()
    }
}
