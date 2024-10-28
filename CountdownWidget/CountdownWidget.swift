//
//  CountdownWidget.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            countdownItem: nil)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration,
                    countdownItem: nil)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        let items = await getCountdownItems()
        
        // Generate a timeline consisting of 24 entries an hour apart, starting from the current date.
        
        //        let currentDate = Date()
        //        for hourOffset in 0 ..< 24 {
        //            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
        //            let entry = SimpleEntry(date: entryDate, configuration: configuration)
        //            entries.append(entry)
        //        }
        
        print("Renewing Timeline")
        print(items)
        
           // If there is no countdowns, set it to never refresh EVER
        if(items.isEmpty){
            return Timeline(entries: [], policy: .never)
        }
        
        print(items.first!.name)
        print(items.first!.date)

        let entries: [SimpleEntry] = [
            SimpleEntry(date: .now, configuration: configuration, countdownItem: items.first),
        ]
        
        // Refresh every after 1 hour
        return Timeline(entries: entries, policy: .after(.now.addingTimeInterval(3600)))
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
    
    static func predicate() -> Predicate<CountdownItem> {
        let now = Date()
        return #Predicate<CountdownItem> { $0.date >= now }
    }
    
    // Fetch all countdown items
    @MainActor
    private func getCountdownItems() -> [CountdownItem] {
        let modelContainer = CountieModelContainer.sharedModelContainer
        
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: Provider.predicate(), sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )
        
        let items = try? modelContainer.mainContext.fetch(descriptor)
        
        return items ?? [];
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let countdownItem: CountdownItem?
}

struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            CountdownWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(CountieModelContainer.sharedModelContainer)
        }
        .supportedFamilies(
            [
                .accessoryRectangular,
                .systemSmall,
                .systemMedium,
                .systemLarge
            ])
    }
}

extension ConfigurationAppIntent {
    
    fileprivate static var defaultIntent: ConfigurationAppIntent {
        return ConfigurationAppIntent()
    }
}

#Preview(as: .systemMedium) {
    CountdownWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        configuration: .defaultIntent,
        countdownItem: nil
    )
    
    
}
