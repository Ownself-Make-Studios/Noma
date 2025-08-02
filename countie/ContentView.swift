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

    @AppStorage("filterPast") private var showOnlyPastCountdowns = false

    private func handleFilterClick() {
        showOnlyPastCountdowns.toggle()
    }

    private func deleteItems(offsets: IndexSet) {

        for index in offsets {
            modelContext.delete(countdowns[index])
        }

        try? modelContext.save()

        // Filter from countdowns
        fetchCountdowns()

        print("Deleted item")

        // Ensure widget updates after deletion
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func fetchCountdowns() {

        let now = Date.now

        var descriptor = FetchDescriptor<CountdownItem>(

            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )

        //        if showOnlyPastCountdowns {
        //            descriptor.predicate = #Predicate<CountdownItem> {
        //                $0.date <= now
        //            }
        //        } else {
        //            descriptor.predicate = #Predicate<CountdownItem> {
        //                $0.date >= now
        //            }
        //        }

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
                if countdowns.isEmpty {
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

                    TabView(selection: $selectedTab) {

                        Tab(
                            "Coming Up",
                            systemImage: "calendar.badge.clock",
                            value: .comingup
                        ) {
                            CountdownListView(
                                countdowns: upcomingCountdowns,
                                onDelete: deleteItems
                            )
                        }

                        Tab(
                            "Past Events",
                            systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                            value: .pastevents
                        ) {
                            CountdownListView(
                                countdowns: passedCountdowns,
                                onDelete: deleteItems
                            )

                        }

                        Tab(value: .search, role: .search) {
                            ContentUnavailableView("Work in progress", systemImage: "magnifyingglass", description: Text("This page is a work in progess. Please check back later!"))

                                //                            CountdownListView(
                                //                                countdowns: countdowns,
                                //                                onDelete: deleteItems
                                //                            )
                        }
                    }
                    .tabViewStyle(.tabBarOnly)

                    //                    HStack {
                    //                        Button("Upcoming") {
                    //                            withAnimation {
                    //                                showOnlyPastCountdowns = false
                    //                            }
                    //                        }
                    //                        .foregroundStyle(.primary)
                    //                        .padding()
                    //                        .background(
                    //                            showOnlyPastCountdowns
                    //                                ? Color.clear : Color.primary.opacity(0.2)
                    //                        )
                    //                        .clipShape(Capsule())
                    //
                    //                        Button("Passed") {
                    //                            withAnimation {
                    //                                showOnlyPastCountdowns = true
                    //                            }
                    //                        }
                    //                        .foregroundStyle(.primary)
                    //                        .padding()
                    //                        .background(
                    //                            showOnlyPastCountdowns == false
                    //                                ? Color.clear : Color.primary.opacity(0.2)
                    //                        )
                    //                        .clipShape(Capsule())
                    //                    }
                    //
                    //                    CountdownListView(
                    //                        countdowns: countdowns,
                    //                        onDelete: deleteItems
                    //                    )
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
                    //                    Button(action: handleFilterClick) {
                    //                        Label(
                    //                            "Filter",
                    //                            systemImage: showOnlyPastCountdowns
                    //                                ? "line.3.horizontal.decrease.circle.fill"
                    //                                : "line.3.horizontal.decrease.circle"
                    //                        )
                    //                    }
                    //
                    //                    Spacer()

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
        .onChange(of: showOnlyPastCountdowns) { _, _ in
            withAnimation {
                fetchCountdowns()
            }
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
