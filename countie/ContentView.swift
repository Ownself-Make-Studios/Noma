//
//  ContentView.swift
//  countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftData
import SwiftUI
import WidgetKit

enum Tabs {
    case comingup, pastevents, search

}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var countdowns: [CountdownItem] = []
    @State private var showAddModal = false
    @State private var showCalendarModal = false
    @State private var searchText: String = ""
    @State private var selectedTab: Tabs = .comingup


    private func deleteItemsUpcoming(offsets: IndexSet) {

        for index in offsets {
            modelContext.delete(upcomingCountdowns[index])
        }

        try? modelContext.save()

        // Filter from countdowns
        fetchCountdowns()

        print("Deleted item")

        // Ensure widget updates after deletion
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func deleteItemsPassed(offsets: IndexSet) {

        for index in offsets {
            modelContext.delete(passedCountdowns[index])
        }

        try? modelContext.save()

        // Filter from countdowns
        fetchCountdowns()

        print("Deleted item")

        // Ensure widget updates after deletion
        WidgetCenter.shared.reloadAllTimelines()
    }

    // TODO: Might do some pagination e.g. 12 months of countdowns or by calendar picker
    private func fetchCountdowns() {
        let descriptor = FetchDescriptor<CountdownItem>(

            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )

        let fetchedItems = try? modelContext.fetch(descriptor)

        countdowns = fetchedItems ?? []
    }

    var upcomingCountdowns: [CountdownItem] {
        countdowns.filter { $0.date >= Date.now }
    }

    var passedCountdowns: [CountdownItem] {
        countdowns.filter { $0.date < Date.now }
    }

    var body: some View {
        NavigationStack {
            VStack {

                TabView(selection: $selectedTab) {

                    Tab(
                        "Coming Up",
                        systemImage: "calendar.badge.clock",
                        value: .comingup
                    ) {
                        if upcomingCountdowns.isEmpty {
                            Spacer(minLength: 0)
                            ContentUnavailableView(
                                "No Countdowns Yet :(",
                                systemImage: "calendar",
                                description: Text(
                                    "Add a countdown by tapping the plus button!"
                                )
                            )
                            Spacer(minLength: 0)
                        } else {
                            CountdownListView(
                                countdowns: upcomingCountdowns,
                                onDelete: deleteItemsUpcoming
                            )
                        }
                    }

                    Tab(
                        "Past Events",
                        systemImage:
                            "clock.arrow.trianglehead.counterclockwise.rotate.90",
                        value: .pastevents
                    ) {
                        
                        if passedCountdowns.isEmpty {
                            Spacer(minLength: 0)
                            ContentUnavailableView(
                                "No Past Countdowns",
                                systemImage: "calendar",
                                description: Text(
                                    "Add one by tapping the plus button"
                                )
                            )
                            Spacer(minLength: 0)
                        } else {
                            
                            CountdownListView(
                                countdowns: passedCountdowns,
                                onDelete: deleteItemsPassed
                            )
                        }

                    }

                    //                        Tab(value: .search, role: .search) {
                    //                            ContentUnavailableView(
                    //                                "Work in progress",
                    //                                systemImage: "magnifyingglass",
                    //                                description: Text(
                    //                                    "This page is a work in progess. Please check back later!"
                    //                                )
                    //                            )
                    //
                    //                        }
                }

            }
            .toolbar {

                ToolbarItem {

                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                            .labelStyle(.titleAndIcon)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {
                            showCalendarModal = true
                        }) {
                            Label(
                                "Add from calendar",
                                systemImage: "calendar.badge.plus"
                            )
                        }

                        Button(action: {
                            showAddModal = true
                        }) {
                            Label("Custom", systemImage: "plus")
                                .labelStyle(.titleAndIcon)
                        }

                    } label: {
                        Label("Add Countdown", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }
                }

            }
            .navigationTitle("Countie")
        }
        .sheet(isPresented: $showAddModal) {
            NavigationView {
                AddCountdownView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showAddModal = false
                            }
                        }

                    }
            }
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showCalendarModal) {
            NavigationView {
                CalendarEventsView(
                    onSelectEvent: { _ in
                        showAddModal = false
                        showCalendarModal = false
                        fetchCountdowns()
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showCalendarModal = false
                        }
                    }

                }
            }
            .navigationTitle("Add from Calendar")
        }
        .onChange(of: showAddModal) { oldValue, newValue in
            if oldValue != newValue && newValue == false {
                // AddCountdownView was dismissed
                fetchCountdowns()
            }
        }
        .task {
            fetchCountdowns()
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(CountieModelContainer.sharedModelContainer)
    //        .modelContainer(for: CountdownItem.self, inMemory: true)
}
