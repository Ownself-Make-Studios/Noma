//
//  MultipleCountdownWidget.swift
//  MultipleCountdownWidget
//
//  Created by Nabil Ridhwan on 25/6/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            countdowns: [
                .init(emoji: "🎉", name: "Welcome to Countie!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 3)),
                .init(emoji: "🎂", name: "My Birthday", includeTime: true, date: Date().addingTimeInterval(60 * 60 * 24 * 5)),
                .init(emoji: "🎈", name: "Party Time!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 7)),
                .init(emoji: "🎊", name: "New Year Celebration", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 10))
                
            ]
        )
    }
    
    func snapshot(for configuration: MultipleCountdownConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            countdowns: [
                .init(emoji: "🎉", name: "Welcome to Countie!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 3)),
                .init(emoji: "🎂", name: "My Birthday", includeTime: true, date: Date().addingTimeInterval(60 * 60 * 24 * 5)),
                .init(emoji: "🎈", name: "Party Time!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 7)),
                .init(emoji: "🎊", name: "New Year Celebration", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 10))
            ]
        )
    }
    
    func timeline(for configuration: MultipleCountdownConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        var entries: [SimpleEntry] = []
        
        let countdowns = await getLatestCountdowns()
        
        if let safeCountdowns = countdowns {
            for countdown in safeCountdowns {
                entries.append(SimpleEntry(date: countdown.date, countdowns: safeCountdowns))
            }
        }else{
            return Timeline(entries: entries, policy: .never)
        }
        
        return Timeline(entries: entries, policy: .after(Date().addingTimeInterval(60 * 60 * 1))) // Refresh every 1 hour
    }
    
    // Fetch latest active countdowns
    @MainActor
    private func getLatestCountdowns(count: Int = 4) -> [CountdownItem]? {
        
        let modelContainer = CountieModelContainer.sharedModelContainer
        
        let now = Date()
        
        var descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { $0.date >= now },
            sortBy: [SortDescriptor(\CountdownItem.date, order: .forward)],
        )
        
        descriptor.fetchLimit = count
        
        do {
            let items = try modelContainer.mainContext.fetch(descriptor)
            print(items.count)
            return items
        }catch {
            print("Error fetching countdowns: \(error)")
            return nil
        }
    }
    
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let countdowns: [CountdownItem]
}

struct MultipleCountdownWidget: Widget {
    let kind: String = "MultipleCountdownWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MultipleCountdownConfigurationAppIntent.self, provider: Provider()) { entry in
            MultipleCountdownWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(CountieModelContainer.sharedModelContainer)
            
            
            
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Multiple Countdowns Widget")
        .description("Keep track of up to 3 of your upcoming countdowns with this widget!")
        .supportedFamilies(
            [
                .systemMedium,
            ])
    }
}

#Preview(as: .systemMedium) {
    MultipleCountdownWidget()
} timeline: {
    SimpleEntry(
        date:.now,
        countdowns: [
            .init(emoji: "🎉", name: "Welcome to Countie!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 3)),
            .init(emoji: "🎂", name: "My Birthday", includeTime: true, date: Date().addingTimeInterval(60 * 60 * 24 * 5)),
            .init(emoji: "🎈", name: "Party Time!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 7)),
            .init(emoji: "🎊", name: "New Year Celebration", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 10))
        ]
    )
}
