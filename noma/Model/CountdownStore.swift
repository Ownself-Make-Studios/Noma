//
//  CountdownStore.swift
//  noma
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

    func syncCountdownsWithEvents() {
        if let countdowns = self.fetchCalendarLinkedCountdowns() {
            for countdown in countdowns {
                if let eventIdentifier = countdown.calendarEventIdentifier,
                   let event = self.eventStore.event(withIdentifier: eventIdentifier) {
                    // Update countdown date to match event's start date
                    if countdown.date != event.startDate {
                        countdown.date = event.startDate
                    }
                } else {
                    // Event was deleted or not found, mark countdown as deleted
                    countdown.isDeleted = true
                }
            }
            // Persist changes to the model context
            try? self.context.save()
            // Refresh countdown arrays and UI
            self.fetchCountdowns()
        }
    }

    init(context: ModelContext) {
        self.context = context
        fetchCountdowns()
        syncCountdownsWithEvents() // Sync at launch

        let token = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: self.eventStore,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.syncCountdownsWithEvents()
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
